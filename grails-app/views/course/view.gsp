<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="dk.sdu.tekvideo.FaIcon; dk.danthrane.twbs.ButtonStyle; dk.danthrane.twbs.ButtonSize" %>
<html>
<head>
    <meta name="layout" content="main_fluid">
    <title>${course.name}</title>
</head>

<body>

<twbs:pageHeader>
    <h3>${course.fullName} (${course.name})</h3>
</twbs:pageHeader>

%{-- Should be automatic --}%
<twbs:row>
    <twbs:column>
        <ol class="breadcrumb">
            <li><g:link uri="/">Hjem</g:link></li>
            <li>
                <sdu:linkToTeacher teacher="${course.teacher}">
                    ${course.teacher}
                </sdu:linkToTeacher>
            </li>
            <li class="active">${course.fullName} (${course.name})</li>
        </ol>
    </twbs:column>
</twbs:row>

<g:each in="${course.visibleSubjects}" var="subject">
    <sdu:card>
        <twbs:row>
            <twbs:column>
                <h5><sdu:linkToSubject subject="${subject}">${subject.name}</sdu:linkToSubject></h5>
            </twbs:column>
        </twbs:row>
        <twbs:row>
            <twbs:column cols="6">
                <markdown:renderHtml>${subject.description}</markdown:renderHtml>

                <hr>
                <b>Du har i dette emne</b><br />
                <ul>
                    <li>Gennemført 3 ud af 5 videoer</li>
                    <li>Svaret rigtigt på 92% af spørgsmålene</li>
                </ul>
            </twbs:column>
            <twbs:column cols="6">
                <ul class="course-subject-menu">
                    <g:each in="${subject.visibleVideos}" var="video">
                        <li>
                            <twbs:buttonGroup size="${ButtonSize.SMALL}">
                                <twbs:button style="${ButtonStyle.PRIMARY}">
                                    <fa:icon icon="${FaIcon.YOUTUBE_PLAY}"/>
                                </twbs:button>
                                <twbs:button style="${ButtonStyle.INFO}">
                                    <fa:icon icon="${FaIcon.LINE_CHART}"/>
                                </twbs:button>
                                <twbs:button style="${ButtonStyle.INFO}">
                                    <fa:icon icon="${FaIcon.PENCIL}"/>
                                </twbs:button>
                            </twbs:buttonGroup>
                            <a href="#">${video.name}</a>
                            <span class="text-success">[<fa:icon icon="${FaIcon.CHECK}"/>]</span>
                        </li>
                    </g:each>
                </ul>
            </twbs:column>
        </twbs:row>
    </sdu:card>
</g:each>

<g:content key="sidebar-left">
    <twbs:pageHeader><h6>Dette fag <small>${course.name}</small></h6></twbs:pageHeader>
    <markdown:renderHtml>${course.description}</markdown:renderHtml>
</g:content>

<g:render template="sidebar" model="${pageScope.variables}"/>
</body>
</html>