class Texts { 
    public static String textRow(leftSpace, rightSpace, leftContent, rightContent) {
        return String.format("║ %-${leftSpace}s │ %-${rightSpace}s ║", leftContent, rightContent)
    }

    public static String getVersion (json, tool) {
        if (json[tool] && json[tool]['version']) {
            return json[tool]['version']
        }
        return 'no version information'
    }

    public static String getImage (json, tool) {
        if (json[tool] && json[tool]['container']) {
            return json[tool]['container']
        }
        return 'no image information'
    }

    public static String coreTextRow(title, value) {
        return textRow(25, 67, title, value)
    }

    public static String dbTextRow(title, value) {
        return textRow(13, 79, title, value)
    }

    public static String toolTextRow(json, title, tool) {
        return textRow(30, 62, title, getVersion(json, tool))
    }

    public static String imageTextRow (json, title, tool) {
        return textRow(30, 62, title, getImage(json, tool))
    }

    public static String ioTextRow(title, value) {
        return textRow(8, 84, title, value)
    }

    public static String assemblerTextRow(title, value) {
        return textRow(25, 67, title, value)
    }

    public static String qcTextRow(title, value) {
        return textRow(60, 32, title, value)
    }

    public static String containerEngineTextRow(title, value) {
        return textRow(25, 67, title, value)
    }
}