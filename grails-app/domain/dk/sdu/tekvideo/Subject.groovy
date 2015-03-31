package dk.sdu.tekvideo

class Subject {
    String name

    static hasMany = [videos: Video]

    static constraints = {
        name nullable: false, blank: false
    }

    static belongsTo = Course
}