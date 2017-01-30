package dk.sdu.tekvideo

import grails.converters.JSON
import org.springframework.security.access.annotation.Secured

class ExerciseController {
    def urlMappingService
    def exerciseService
    def nodeService

    @Secured("permitAll")
    def view(String teacherName, String courseName, String subjectName, Integer videoId, Integer year, Boolean spring) {
        Exercise exercise = urlMappingService.getExercise(teacherName, courseName, subjectName, videoId, year, spring)
        if (nodeService.canView(exercise)) {
            if (exercise instanceof Video) {
                forward controller: "video", action: "viewV", params: [id: exercise.id]
            } else if (exercise instanceof WrittenExerciseGroup) {
                forward controller: "writtenExercise", action: "view", params: [id: exercise.id]
            } else {
                render status: 500, text: "Unable to view exercise"
            }
        } else {
            render status: 404, text: "Unable to find exercise!"
        }
    }

    @Secured(["ROLE_STUDENT", "ROLE_TEACHER"])
    def postComment(CreateCommentCommand command) {
        def result = exerciseService.createComment(command)
        if (result.success) {
            flash.success = "Din kommentar er blevet tilføjet til videoen"
        } else {
            flash.error = "Der skete en fejl!"
        }

        redirect url: urlMappingService.generateLinkToExercise(command.id, [absolute: true])
    }

    @Secured(["ROLE_TEACHER"])
    def deleteComment(Long id, Long comment) {
        Exercise e = Exercise.get(id)
        def result = exerciseService.deleteComment(e, Comment.get(comment))
        render result as JSON
    }
}
