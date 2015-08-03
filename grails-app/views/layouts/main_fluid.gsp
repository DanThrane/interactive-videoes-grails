<%@ page import="dk.sdu.tekvideo.FaIcon" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>TekVideo | <g:layoutTitle default="Title"/></title>
    <g:layoutHead/>
    <asset:stylesheet src="application.css"/>
    <asset:javascript src="application.js"/>
    <fa:require />
    <link rel="shortcut icon" href="${asset.assetPath(src: "favicon.ico")}" />

    <script>
        $(function() {
            var start = Date.now();
            events.configure("${createLink(controller: "event", action: "register")}");
            events.start();

            events.emit({
                "kind": "VISIT_SITE",
                "url": document.location.href,
                "ua": navigator.userAgent
            }, true);

            window.onbeforeunload = function() {
                events.emit({
                    "kind": "EXIT_SITE",
                    "url": document.location.href,
                    "ua": navigator.userAgent,
                    "time": Date.now() - start
                });
                events.flush(false);
            };
        });
    </script>
</head>
<body>

<twbs:navbar>
    <g:content key="navbar-brand">
        TekVideo
    </g:content>
    <twbs:navbarLinks>
        <twbs:navbarLink action="list" controller="course">Kurser</twbs:navbarLink>

        <sec:ifAllGranted roles="ROLE_TEACHER">
            <twbs:navbarLink controller="courseManagement">Mine kurser</twbs:navbarLink>
        </sec:ifAllGranted>
    </twbs:navbarLinks>
    <twbs:navbarPullRight>
        <twbs:navbarLinks>
            <sec:ifNotLoggedIn>
                <twbs:navbarLink method="POST" controller="login" action="">Log ind</twbs:navbarLink>
            </sec:ifNotLoggedIn>
            <sec:ifLoggedIn>
                <sec:ifAllGranted roles="ROLE_TEACHER">
                    <twbs:navbarLink controller="admin">Admin Panel</twbs:navbarLink>
                </sec:ifAllGranted>
                <twbs:navDropdownToggle>
                    <fa:icon icon="${FaIcon.USER}" /> <sdu:username />
                    <twbs:dropdownMenu>
                        <twbs:dropdownDivider />
                        <twbs:dropdownItem method="POST" controller="logout" action="">Log ud</twbs:dropdownItem>
                    </twbs:dropdownMenu>
                </twbs:navDropdownToggle>
            </sec:ifLoggedIn>
        </twbs:navbarLinks>
    </twbs:navbarPullRight>
</twbs:navbar>

<twbs:container fluid="true">
    <g:if test="${flash.error}">
        <twbs:alert type="danger">${flash.error}</twbs:alert>
    </g:if>
    <g:if test="${flash.warning}">
        <twbs:alert type="warning">${flash.warning}</twbs:alert>
    </g:if>
    <g:if test="${flash.success}">
        <twbs:alert type="success">${flash.success}</twbs:alert>
    </g:if>
    <g:if test="${flash.message}">
        <twbs:alert type="info">${flash.message}</twbs:alert>
    </g:if>
    <twbs:row>
        <g:ifContentAvailable key="sidebar-right">
            <twbs:column sm="8" push-sm="2">
                <g:layoutBody/>
            </twbs:column>
            <twbs:column sm="2" pull-sm="8" class="sidebar">
                Left
            </twbs:column>
            <twbs:column sm="2" class="sidebar">
                Right
            </twbs:column>
        </g:ifContentAvailable>
        <g:ifContentNotAvailable key="sidebar-right">
            <twbs:column sm="10" push-sm="2" class="content">
                <g:layoutBody/>
            </twbs:column>
            <twbs:column sm="2" pull-sm="10" class="sidebar">
                Left
            </twbs:column>
        </g:ifContentNotAvailable>
    </twbs:row>
</twbs:container>

<twbs:container fluid="true" id="footer">
    <twbs:row>
        <twbs:column cols="3">
        </twbs:column>
        <twbs:column cols="3">
        </twbs:column>
        <twbs:column cols="6">
            <div class="pull-right">
                <asset:image src="sdu_logo.png" />
            </div>
        </twbs:column>
    </twbs:row>
</twbs:container>
</body>
</html>