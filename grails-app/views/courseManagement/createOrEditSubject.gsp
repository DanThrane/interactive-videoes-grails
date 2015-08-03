<%@ page import="dk.sdu.tekvideo.FaIcon; dk.danthrane.twbs.ButtonStyle" contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Nyt emne</title>
    <meta name="layout" content="main" />
    <asset:javascript src="list.js" />
    <sdu:requireAjaxAssets />
</head>

<body>
<twbs:row>
    <twbs:column>
        %{-- TODO Refactor this --}%
        <twbs:pageHeader>
            <h3>
                <g:if test="${isEditing}">
                    Administreing af emne
                    <small>${command.domain.name}</small>
                </g:if>
                <g:else>
                    Nyt emne
                </g:else>
            </h3>
        </twbs:pageHeader>

        <h4>Grundlæggende detaljer</h4>
        <twbs:form method="POST" action="${createLink(action: "postSubject", id: course.id)}">
            <sducrud:hiddenFields />

            <twbs:input name="domain.name" bean="${command?.domain}" labelText="Navn" />
            <twbs:textArea name="domain.description" bean="${command?.domain}" labelText="Beskrivelse"
                           rows="10" />

            <sducrud:saveButton />
        </twbs:form>

        <hr>

        <g:if test="${isEditing}">
            <h4>Videoer</h4>

            <blockquote>
                Help text goes here
            </blockquote>

            <g:if test="${!command.domain.videos?.isEmpty()}">
                <div id="video-container">
                    <g:each in="${command.domain.videos}" var="video" status="idx">
                        <sdu:card class="video">
                            <div data-video-id="${video.id}" class="hide"></div>
                            <twbs:row>
                                <twbs:column cols="8">
                                    <h6>${video.name}</h6>
                                </twbs:column>
                                <twbs:column cols="4" class="align-right">
                                    <twbs:buttonToolbar>
                                        <twbs:linkButton style="${ButtonStyle.LINK}" mapping="teaching"
                                                         params="${[teacher: teacher, course: course,
                                                                    subject: command.domain, vidid: idx]}">
                                            <fa:icon icon="${FaIcon.YOUTUBE_PLAY}" />
                                        </twbs:linkButton>
                                        <twbs:linkButton style="${ButtonStyle.LINK}" action="editVideo"
                                                         id="${video.id}">
                                            <fa:icon icon="${FaIcon.EDIT}" />
                                        </twbs:linkButton>
                                        <twbs:button style="${ButtonStyle.SUCCESS}" class="video-up">
                                            <fa:icon icon="${FaIcon.ARROW_UP}" />
                                        </twbs:button>
                                        <twbs:button style="${ButtonStyle.DANGER}" class="video-down">
                                            <fa:icon icon="${FaIcon.ARROW_DOWN}" />
                                        </twbs:button>
                                    </twbs:buttonToolbar>
                                </twbs:column>
                            </twbs:row>
                        </sdu:card>
                    </g:each>
                </div>
                <sdu:ajaxSubmitButton style="${ButtonStyle.PRIMARY}" id="save-video-order">
                    <fa:icon icon="${FaIcon.EDIT}" />
                    Gem ændringer
                </sdu:ajaxSubmitButton>
            </g:if>
            <g:else>
                Dette emne har ikke nogle videoer.
            </g:else>
        </g:if>
    </twbs:column>
</twbs:row>

<g:if test="${isEditing}">
    <script>
        $(function () {
            var list = new ListManipulator(".video", ".video-up", ".video-down");
            list.init();

            AjaxUtil.registerJSONForm("#save-video-order", "${createLink(action: "updateVideos")}", function() {
                var order = list.map(function (element) {
                    return parseInt(element.find("[data-video-id]").attr("data-video-id"));
                });

                return { order: order, subject: ${command.domain.id} };
            });
        });
    </script>
</g:if>
</body>
</html>