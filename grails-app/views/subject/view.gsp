<%@ page import="dk.sdu.tekvideo.FaIcon; dk.danthrane.twbs.ButtonStyle" contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="main_fluid">
    <title>Videoer for ${subject.name}</title>
</head>

<body>

<twbs:pageHeader>
    <h3>Videoer <small>${subject.name}</small></h3>
</twbs:pageHeader>

%{-- Should be automatic --}%
<twbs:row>
    <twbs:column>
        <ol class="breadcrumb">
            <li><g:link uri="/">Hjem</g:link></li>
            <li>
                <g:link mapping="teaching" params="${[teacher: params.teacher]}">
                    ${params.teacher}
                </g:link>
            </li>
            <li>
                <g:link mapping="teaching" params="${[teacher: params.teacher, course: params.course]}">
                    ${subject.course.fullName} (${subject.course.name})
                </g:link>
            </li>
            <li class="active">${subject.name}</li>
        </ol>
    </twbs:column>
</twbs:row>

<g:each status="i" in="${subject.videos}" var="video">
    <sdu:linkCard mapping="teaching" params="${[teacher: params.teacher, subject: params.subject,
                                                course: params.course, vidid: i]}">
        <twbs:column cols="2">
            <img src="http://img.youtube.com/vi/${video.youtubeId}/hqdefault.jpg" class="img-responsive" alt="Video thumbnail">
        </twbs:column>
        <twbs:column cols="10">
            <g:link mapping="teaching" params="${[teacher: params.teacher, subject: params.subject,
                                                  course: params.course, vidid: i]}">
                ${video.name}
            </g:link>
            <p>
                ${video.description}
            </p>
        </twbs:column>
    </sdu:linkCard>
</g:each>

<g:content key="sidebar-right">
    <div class="sidebar-options-no-header">
        <twbs:linkButton style="${ButtonStyle.LINK}" block="true"
                         controller="course" action="signup" id="${subject.course.id}">
            <fa:icon icon="${FaIcon.USER_PLUS}" />
            Tilmelding/Afmelding
        </twbs:linkButton>
    </div>
</g:content>

</body>
</html>