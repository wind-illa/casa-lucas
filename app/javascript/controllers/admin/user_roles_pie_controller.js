import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    labels: Array,
    values: Array
  }

  connect() {
    if (!this.labelsValue || !this.valuesValue) {
      console.warn("No labels or values provided for pie chart")
      return
    }
    if (this.valuesValue.length === 0 || this.valuesValue.reduce((a,b) => a + b, 0) === 0) {
      console.warn("Empty or zero-sum data for pie chart")
      return
    }
    this.renderPie()
    this.renderLegend()
  }

  renderPie() {
    const svg = this.element.querySelector("svg")
    svg.innerHTML = ""

    const values = this.valuesValue
    const labels = this.labelsValue
    const total = values.reduce((sum, val) => sum + val, 0)

    let cumulativePercent = 0

    values.forEach((val, i) => {
      const percent = val / total
      const [startX, startY] = this.getCoordinatesForPercent(cumulativePercent)
      cumulativePercent += percent
      const [endX, endY] = this.getCoordinatesForPercent(cumulativePercent)
      const largeArcFlag = percent > 0.5 ? 1 : 0

      const pathData = [
        `M 16 16`,
        `L ${startX * 16 + 16} ${startY * 16 + 16}`,
        `A 16 16 0 ${largeArcFlag} 1 ${endX * 16 + 16} ${endY * 16 + 16}`,
        `Z`
      ].join(" ")

      const path = document.createElementNS("http://www.w3.org/2000/svg", "path")
      path.setAttribute("d", pathData)
      path.setAttribute("fill", this.getColor(labels[i]))
      svg.appendChild(path)
    })

    // Hueco blanco en el centro (donut)
    const centerCircle = document.createElementNS("http://www.w3.org/2000/svg", "circle")
    centerCircle.setAttribute("cx", "16")
    centerCircle.setAttribute("cy", "16")
    centerCircle.setAttribute("r", "8")  // Ajusta el radio a tu gusto
    centerCircle.setAttribute("fill", "white")
    svg.appendChild(centerCircle)

    this.renderCenterText(total)
  }

  renderCenterText(total) {
    const svg = this.element.querySelector("svg")

    const text = document.createElementNS("http://www.w3.org/2000/svg", "text")
    text.setAttribute("x", "50%")
    text.setAttribute("y", "52%")
    text.setAttribute("text-anchor", "middle")
    text.setAttribute("dominant-baseline", "middle")  // centra verticalmente
    text.setAttribute("font-size", "6")
    text.setAttribute("font-weight", "bold")
    text.setAttribute("fill", "#444")
    text.textContent = total

    svg.appendChild(text)
  }


  renderLegend() {
    let legend = this.element.querySelector(".pie-legend")
    if (!legend) {
      legend = document.createElement("div")
      legend.classList.add("pie-legend")
      this.element.appendChild(legend)
    }
    legend.innerHTML = ""

    const values = this.valuesValue
    const labels = this.labelsValue
    const total = values.reduce((sum, val) => sum + val, 0)

    labels.forEach((label, i) => {
      const value = values[i]
      const percent = total === 0 ? 0 : Math.round((value / total) * 100)


      const item = document.createElement("div")
      item.classList.add("legend-item")

      const colorBox = document.createElement("span")
      colorBox.classList.add("legend-color")
      colorBox.style.backgroundColor = this.getColor(label)

      const text = document.createElement("span")
      text.classList.add("legend-label")
      text.textContent = `${label} - ${percent}%`

      item.appendChild(colorBox)
      item.appendChild(text)
      legend.appendChild(item)
    })
  }

  getCoordinatesForPercent(percent) {
    const x = Math.cos(2 * Math.PI * percent)
    const y = Math.sin(2 * Math.PI * percent)
    return [x, y]
  }

  getColor(label) {
    const colorMap = {
      "Administradores": "#7086FD",
      "Repositores": "#1cc88a",
      "Cajeros": "#36b9cc",
      "Clientes Regular": "#FFAE4C",
      "Clientes Mayorista": "#1F94FF"
    }
    return colorMap[label] || "#cccccc"
  }
}
