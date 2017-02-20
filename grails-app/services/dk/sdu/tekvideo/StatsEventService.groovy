package dk.sdu.tekvideo

import dk.sdu.tekvideo.stats.AnswerVideoCommand
import dk.sdu.tekvideo.stats.AnswerVideoDetails
import dk.sdu.tekvideo.stats.EventHandler
import dk.sdu.tekvideo.stats.VideoAnswer
import dk.sdu.tekvideo.stats.VideoAnswerDetails
import dk.sdu.tekvideo.stats.VideoProgress
import dk.sdu.tekvideo.stats.VideoVisit
import org.apache.http.HttpStatus

class StatsEventService implements EventHandler {
    static final String EVENT_ANSWER_QUESTION = "ANSWER_QUESTION"
    static final Set<String> KNOWN_EVENTS = Collections.unmodifiableSet([EVENT_ANSWER_QUESTION].toSet())

    @Override
    boolean canHandle(String eventKind) {
        return eventKind in KNOWN_EVENTS
    }

    @Override
    ServiceResult<Void> handle(Event event) {
        switch (event.kind) {
            case EVENT_ANSWER_QUESTION:
                return handleAnswerQuestion(event)
            default:
                return ServiceResult.fail(
                        message: "Internal error",
                        internal: true,
                        suggestedHttpStatus: HttpStatus.SC_INTERNAL_SERVER_ERROR,
                        information: [why: "Unhandled event kind ${event.kind}"]
                )
        }
    }

    private ServiceResult<Void> handleAnswerQuestion(Event event) {
        def videoResult = eventProperty(event, "video", Integer)
        def subjectResult = eventProperty(event, "subject", Integer)
        def questionResult = eventProperty(event, "question", Integer)
        def correctResult = eventProperty(event, "correct", Boolean)
        def detailsResult = eventProperty(event, "details", List)

        def errors = checkForErrors(videoResult, subjectResult, questionResult, correctResult, detailsResult)
        if (errors) return errors

        def video = Video.get(videoResult.result)
        if (video == null) {
            return ServiceResult.fail(
                    message: "Not found",
                    suggestedHttpStatus: HttpStatus.SC_NOT_FOUND
            )
        }

        def command = new AnswerVideoCommand()
        command.correct = correctResult.result
        command.question = questionResult.result
        command.subject = subjectResult.result
        command.video = video

        command.details = detailsResult.result.collect {
            def answerResult = dynamicProperty(it, "answer", String)
            def detailsCorrectResult = dynamicProperty(it, "correct", Boolean)
            def fieldResult = dynamicProperty(it, "field", Integer)

            def detailsErrors = checkForErrors(answerResult, detailsCorrectResult, fieldResult)
            if (detailsErrors) return null

            def result = new AnswerVideoDetails()
            result.correct = detailsCorrectResult.result
            result.answer = answerResult.result
            result.field = fieldResult.result
            return result
        }.findAll { it != null }

        if (command.details.empty) {
            return ServiceResult.fail(
                    message: "No details provided",
                    suggestedHttpStatus: HttpStatus.SC_BAD_REQUEST
            )
        }

        def progress = getVideoProgress(video, event.user, event.uuid)
        addAnswer(progress, command)
        return ServiceResult.ok()
    }

    VideoProgress getVideoProgress(Video video, User user, String uuid = null) {
        assert user != null || uuid != null

        VideoProgress result
        if (user != null) {
            result = VideoProgress.findByVideoAndUser(video, user)
        } else {
            result = VideoProgress.findByVideoAndUuid(video, uuid)
        }

        if (result == null) {
            result = new VideoProgress(video: video, user: user, uuid: uuid).save(flush: true)
        }
        return result
    }

    VideoVisit addVisit(VideoProgress progress, boolean save = true, boolean flush = true) {
        def result = new VideoVisit(
                progress: progress,
                timestamp: new Date(System.currentTimeMillis())
        )
        if (save) {
            result.save(flush: flush)
        }
        return result
    }

    VideoAnswer addAnswer(VideoProgress progress, AnswerVideoCommand command) {
        def answer = new VideoAnswer(
                progress: progress,
                correct: command.correct,
                subject: command.subject,
                question: command.question
        ).save(flush: true)

        command.details.collect {
            new VideoAnswerDetails(
                    parent: answer,
                    answer: it.answer,
                    correct: it.correct,
                    field: it.field
            )
        }.findAll { it != null }.each { it.save(flush: true) }
        return answer
    }

    private <T> ServiceResult<T> dynamicProperty(obj, String key, Class<T> type) {
        if (obj[key] != null) {
            def property = obj[key]
            if (type.isInstance(property)) {
                return ServiceResult.ok(type.cast(property))
            } else {
                return ServiceResult.fail(
                        message: "Bad request",
                        suggestedHttpStatus: HttpStatus.SC_BAD_REQUEST,
                        information: [why: "Invalid type for '$key'. " +
                                "Expected ${type.simpleName} got ${property.class.simpleName}"]
                )
            }
        }

        return ServiceResult.fail(
                message: "Bad request",
                suggestedHttpStatus: HttpStatus.SC_BAD_REQUEST,
                informatino: [why: "Property '$key' does not exist on event."]
        )
    }

    private <T> ServiceResult<T> eventProperty(Event event, String key, Class<T> type) {
        if (event.additionalData.containsKey(key)) {
            def property = event.additionalData.get(key)
            if (type.isInstance(property)) {
                return ServiceResult.ok(type.cast(property))
            } else {
                return ServiceResult.fail(
                        message: "Bad request",
                        suggestedHttpStatus: HttpStatus.SC_BAD_REQUEST,
                        information: [why: "Invalid type for '$key'. " +
                                "Expected $type got ${property.class.simpleName}"]
                )
            }
        }

        return ServiceResult.fail(
                message: "Bad request",
                suggestedHttpStatus: HttpStatus.SC_BAD_REQUEST,
                informatino: [why: "Property '$key' does not exist on event."]
        )
    }

    private <T> ServiceResult<T> checkForErrors(ServiceResult... result) {
        return result.find { !it.success }?.convertFailure()
    }
}
