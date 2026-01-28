import QtQuick 6.5

Text {
    id: fish

    property string glyphRight
    property string glyphLeft
    property int direction: 1
    property real speed: 12000
    property real baseY: 80
    property real turnChance: 0.3

    font.family: "monospace"
    opacity: 0.85
    y: baseY

    function applyGlyph() {
        text = (direction === 1) ? glyphRight : glyphLeft
    }

    function resetPosition() {
        x = (direction === 1) ? -width : parent.width
    }

    function maybeTurn() {
        if (Math.random() < turnChance)
            direction *= -1
    }

    Component.onCompleted: {
        direction = (Math.random() < 0.5) ? 1 : -1
        applyGlyph()
        resetPosition()
        swim.restart()
    }

    NumberAnimation {
        id: swim
        target: fish
        property: "x"
        from: (fish.direction === 1) ? -fish.width : parent.width
        to:   (fish.direction === 1) ? parent.width : -fish.width
        duration: fish.speed
        loops: 1

        onFinished: {
            fish.maybeTurn()
            fish.applyGlyph()
            fish.resetPosition()
            swim.restart()
        }
    }

    SequentialAnimation on y {
        loops: Animation.Infinite
        NumberAnimation {
            from: fish.baseY - 3
            to:   fish.baseY + 3
            duration: 5000
            easing.type: Easing.InOutSine
        }
        NumberAnimation {
            from: fish.baseY + 3
            to:   fish.baseY - 3
            duration: 5000
            easing.type: Easing.InOutSine
        }
    }
}
