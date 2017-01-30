package dk.sdu.tekvideo

class CourseService implements ContainerNodeInformation<Course, Subject> {
    def urlMappingService
    def videoService

    // Course specific operations

    int getStudentCount(Course course) {
        CourseStudent.countByCourse(course)
    }

    List<Course> listVisibleCourses() {
        def visible = Course.findAllByLocalStatus(NodeStatus.VISIBLE)
        visible.sort()
    }

    List<Course> listActiveCourses() {
        Course.findAllByLocalStatusNotEqual(NodeStatus.TRASH)
    }

    // General "node" operations

    @Override
    String getThumbnail(Course course) {
        // TODO Performance. Also this doesn't cover all exercises
        return videoService.getThumbnail((Video) course.activeSubjects.first()?.activeVideos?.find {
            it instanceof Video
        })
    }

    @Override
    List<NodeBrowserCrumbs> getBreadcrumbs(Course course) {
        [
                new NodeBrowserCrumbs(
                        course.teacher.toString(),
                        urlMappingService.generateLinkToTeacher(course.teacher)
                ),
                new NodeBrowserCrumbs(
                        course.name,
                        urlMappingService.generateLinkToCourse(course)
                )
        ]
    }

    @Override
    NodeBrowserInformation getInformationForBrowser(Course course, boolean addBreadcrumbs) {
        List<NodeBrowserCrumbs> breadcrumbs = []
        if (addBreadcrumbs) breadcrumbs += new NodeBrowserCrumbs(
                course.teacher.toString(),
                urlMappingService.generateLinkToTeacher(course.teacher)
        )

        return new NodeBrowserInformation(
                "${course.name} (${course.fullName})",
                course.description,
                getThumbnail(course),
                urlMappingService.generateLinkToCourse(course),
                breadcrumbs
        )
    }

    @Override
    List<Subject> listVisibleChildren(Course course) {
        return course.visibleSubjects
    }

    @Override
    List<Subject> listActiveChildren(Course course) {
        return course.activeSubjects
    }
}
