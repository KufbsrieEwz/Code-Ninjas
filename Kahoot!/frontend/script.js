let canvas = document.getElementById('canvas')
let c = canvas.getContext('2d')
canvas.width = window.innerWidth
canvas.height = window.innerHeight
c.imageSmoothingEnabled = false
class Vector2 {
    constructor(x, y) {
        this.x = x
        this.y = y
    }
    add(that) {
        return new Vector2(this.x + that.x, this.y + that.y)
    }
    multiply(that) {
        return new Vector2(this.x * that, this.y * that)
    }
    toPolar() {
        return {
            a: Math.atan2(this.y, this.x),
            r: Math.sqrt(this.x ** 2 + this.y ** 2)
        }
    }
    normalize() {
        return Vector2.polar(this.toPolar().a, 1)
    }
    inBoundsRect(thatMin, thatMax) {
        let relativeThis = this.add(thatMin.multiply(-1))
        return (
            (
                0 < relativeThis.x
                &&
                relativeThis.x < thatMax.x
            )
            &&
            (
                0 < relativeThis.y
                &&
                relativeThis.y < thatMax.y
            )
        )
    }
    floor() {
        return new Vector2(Math.floor(this.x), Math.floor(this.y))
    }
    ceil() {
        return new Vector2(Math.ceil(this.x), Math.ceil(this.y))
    }
}
Vector2.unit = new Vector2(1, 1)
Vector2.zero = new Vector2(0, 0)
Vector2.polar = (a, r) => {
    return new Vector2(Math.cos(a), Math.sin(a)).multiply(r)
}
Vector2.random = () => {
    return new Vector2(Math.random() * 2 - 1, Math.random() * 2 - 1)
}
function drawRect(pos, dim, r, g, b, a) {
    c.fillStyle = `rgba(${r}, ${g}, ${b}, ${a})`
    c.fillRect(pos.x, pos.y, dim.x, dim.y)
}
function drawLine(list, r, g, b, a) {
    c.strokeStyle = `rgba(${r}, ${g}, ${b}, ${a})`
    c.beginPath()
    c.moveTo(list[0].x, list[0].y)
    for (let i of list) {
        c.lineTo(i.x, i.y)
    }
    c.stroke()
}
function drawPoly(list, r, g, b, a) {
    c.strokeStyle = `rgba(${r}, ${g}, ${b}, ${a})`
    c.beginPath()
    c.moveTo(list[0].x, list[0].y)
    for (let i of list) {
        c.lineTo(i.x, i.y)
    }
    c.stroke()
    c.fill()
}
function drawArc(pos, rad, sa, ea, clock, r, g, b, a) {
    c.strokeStyle = `rgba(${r}, ${g}, ${b}, ${a})`
    c.fillStyle = `rgba(${r}, ${g}, ${b}, ${a})`
    c.beginPath()
    c.arc(pos.x, pos.y, rad, sa, ea, !clock)
    c.stroke()
    c.fill()
}
function drawImg(img, cropPos, cropDim, pos, dim) {
    c.drawImage(img, cropPos.x, cropPos.y, cropDim.x, cropDim.y, pos.x, pos.y, dim.x, dim.y)
}
function write(text, pos, r, g, b, a) {
    c.font = '20px Arial'
    c.fillStyle = `rgba(${r}, ${g}, ${b}, ${a})`
    c.fillText(text, pos.x, pos.y)
}
// function writeCentred(text, pos, r, g, b, a) {
//     c.font = '20px Arial'
//     c.fillStyle = `rgba(${r}, ${g}, ${b}, ${a})`
//     c.fillText(text, pos.x, pos.y)
// }
function clear() {
    c.clearRect(0, 0, window.innerWidth, window.innerHeight)
}
let gameState
/** gameState legend:
 * 'asking': a question is being presented to the ninja
 * 'answering': the ninja has been presented with potential answers and is picking one
 * 'answered': the ninja has picked an answer and is waiting to see if they got it correct
 * 'responded': the ninja is being told if they got it correct or not along with other gameData that is relevant
 */
// the string values can be replaced with numbers later on
// the strings are just for readability
let question = ''
let answers = {
    A: 'A',
    B: 'B',
    C: 'C',
    D: 'D'
}
let mouse = Vector2.zero
function run() {
    clear()
    switch (gameState) {
        case 'asking':
            drawRect(Vector2.zero, new Vector2(canvas.width, canvas.height).multiply(0.5), 232, 62, 68, 1)
            drawRect(new Vector2(canvas.width / 2, 0), new Vector2(canvas.width, canvas.height).multiply(0.5), 95, 160, 223, 1)
            drawRect(new Vector2(0, canvas.height / 2), new Vector2(canvas.width, canvas.height).multiply(0.5), 245, 195, 68, 1)
            drawRect(new Vector2(canvas.width / 2, canvas.height / 2), new Vector2(canvas.width, canvas.height).multiply(0.5), 124, 188, 78, 1)
            // draw the question prompt
            drawRect(Vector2.zero, new Vector2(canvas.width, canvas.height), 0, 0, 0, 0.5)
            drawRect(new Vector2(0, canvas.height / 4), new Vector2(canvas.width, canvas.height / 2), 0, 0, 0, 0.75)
            break
        case 'answering':
            // draw a header of the question
            drawRect(Vector2.zero, new Vector2(canvas.width, canvas.height / 5), 0, 0, 0, 0.9)
            drawRect(new Vector2(0, canvas.height / 5), new Vector2(canvas.width, canvas.height * 4 / 5).multiply(0.5), 232, 62, 68, 1)
            drawRect(new Vector2(canvas.width / 2, canvas.height / 5), new Vector2(canvas.width, canvas.height * 4 / 5).multiply(0.5), 95, 160, 223, 1)
            drawRect(new Vector2(0, canvas.height * 3 / 5), new Vector2(canvas.width, canvas.height * 4 / 5).multiply(0.5), 245, 195, 68, 1)
            drawRect(new Vector2(canvas.width / 2, canvas.height * 3 / 5), new Vector2(canvas.width, canvas.height * 4 / 5).multiply(0.5), 124, 188, 78, 1)
            discolour(mouse)
            break
        case 'answered':
            // draw a waiting screen so they don't get bored
            break
        case 'responded':
            // draw important information such as if they got it correct and how many points they got
            break
    }
}
function shuffleArray(arr) {
    let indices = arr.map((_, i) => i);
    let shuffledIndices = [...indices].sort(() => Math.random() - 0.5)

    let shuffledArray = shuffledIndices.map(i => arr[i])

    return { shuffledArray, shuffledIndices }
}

function unshuffleArray(shuffledArray, shuffledIndices) {
    let originalArray = new Array(shuffledArray.length)

    shuffledIndices.forEach((originalIndex, i) => {
        originalArray[originalIndex] = shuffledArray[i]
    });

    return originalArray
}
async function click(pos) {
    if (gameState == 'answering') {
        if (pos.inBoundsRect(Vector2.zero, Vector2.zero.add(new Vector2(canvas.width, canvas.height).multiply(0.5)))) {
            // A
            const response = await fetch('http://localhost:3000/check');
            const data = await response.json({ answers: 'A' });
            console.log(data);
        }
        if (pos.inBoundsRect(new Vector2(canvas.width / 2, 0), new Vector2(canvas.width / 2, 0).add(new Vector2(canvas.width, canvas.height).multiply(0.5)))) {
            // B
            console.log('B')
        }
        if (pos.inBoundsRect(new Vector2(0, canvas.height / 2), new Vector2(0, canvas.height / 2).add(new Vector2(canvas.width, canvas.height).multiply(0.5)))) {
            // C
            console.log('C')
        }
        if (pos.inBoundsRect(new Vector2(canvas.width / 2, canvas.height / 2), new Vector2(canvas.width / 2, canvas.height / 2).add(new Vector2(canvas.width, canvas.height).multiply(0.5)))) {
            // D
            console.log('D')
        }
        gameState = 'answered'
    }
}
function discolour(pos) {
    if (pos.inBoundsRect(new Vector2(0, canvas.height / 5), new Vector2(0, canvas.height / 5).add(new Vector2(canvas.width, canvas.height * 4 / 5).multiply(0.5)))) {
        drawRect(new Vector2(0, canvas.height / 5), new Vector2(canvas.width, canvas.height * 4 / 5).multiply(0.5), 0, 0, 0, 0.2)
    }
    if (pos.inBoundsRect(new Vector2(canvas.width / 2, canvas.height / 5), new Vector2(canvas.width / 2, canvas.height / 5).add(new Vector2(canvas.width, canvas.height * 4 / 5).multiply(0.5)))) {
        drawRect(new Vector2(canvas.width / 2, canvas.height / 5), new Vector2(canvas.width, canvas.height * 4 / 5).multiply(0.5), 0, 0, 0, 0.2)
    }
    if (pos.inBoundsRect(new Vector2(0, canvas.height * 3 / 5), new Vector2(0, canvas.height * 3 / 5).add(new Vector2(canvas.width, canvas.height * 4 / 5).multiply(0.5)))) {
        drawRect(new Vector2(0, canvas.height * 3 / 5), new Vector2(canvas.width, canvas.height * 4 / 5).multiply(0.5), 0, 0, 0, 0.2)
    }
    if (pos.inBoundsRect(new Vector2(canvas.width / 2, canvas.height * 3 / 5), new Vector2(canvas.width / 2, canvas.height * 3 / 5).add(new Vector2(canvas.width, canvas.height * 4 / 5).multiply(0.5)))) {
        drawRect(new Vector2(canvas.width / 2, canvas.height * 3 / 5), new Vector2(canvas.width, canvas.height * 4 / 5).multiply(0.5), 0, 0, 0, 0.2)
    }
}
setInterval(run, 1)
document.addEventListener("mousemove", function () {
    mouse = new Vector2(event.x, event.y)
})
document.addEventListener("click", function (event) {
    mouse = new Vector2(event.x, event.y)
    click(mouse)
})
