#let year = 2026

#set document(title: str(year) + " Techo")
#set page(
  "a4",
  flipped: true,
)

#let calendar_table(year, month) = {
  let month_date = datetime(
    year: year,
    month: month,
    day: 1,
  )

  let monthly_days = ()

  for day in range(0, 31) [
    #let month_accumulator = (month_date + duration(days: day))
    #if month_accumulator.month() != month {
      break
    }
    #monthly_days.push(month_accumulator)
  ]

  let p = month_date.display("[month repr:long]")

  align(center)[
    #text(size: 27pt)[#month_date.display("[month repr:long] [year]")
    ]#label(str(p))
  ]

  let first_monday = {
    int(monthly_days.first().display("[weekday repr:monday]"))
  }

  let days = monthly_days.map(day => [
    #let p = day.display("[month repr:long] [day]")
    #link(label(str(p)))[#day.display("[day padding:none]")]
  ])


  show table.cell.where(y: 0): strong
  pad(y: 20pt, table(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    rows: (0.4fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    inset: 12pt,
    table.header([Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday]),
    ..range(1, first_monday).map(empty_day => []),
    ..days,
  ))

  pagebreak(weak: true)
}


#let calendar_mini(year, month) = {
  let month_date = datetime(
    year: year,
    month: month,
    day: 1,
  )

  let monthly_days = ()

  for day in range(0, 31) [
    #let month_accumulator = (month_date + duration(days: day))
    #if month_accumulator.month() != month {
      break
    }
    #monthly_days.push(month_accumulator)
  ]


  let first_monday = {
    int(monthly_days.first().display("[weekday repr:monday]"))
  }

  set text(7pt)
  set table(
    stroke: none,
    gutter: 0.2em,
  )

  let content = {
    show table.cell.where(y: 0): strong
    table(
      columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
      rows: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
      inset: 1pt,
      align: (x, y) => if y == 0 { center } else { right },
      table.header([M], [T], [W], [T], [F], [S], [S]),
      ..range(1, first_monday).map(empty_day => []),
      ..monthly_days.map(day => [#day.display("[day padding:none]")]),
    )
  }
  context [
    #if here().position().x > page.height / 2 [
      #grid(
        columns: (10pt, 1fr),
        rows: auto,
        gutter: 12pt,
        text(size: 17pt)[#month_date.display("[month repr:numerical padding:none]")], content,
      )
    ]
  ]
}



#let date_page(day) = {
  let p = day.display("[month repr:long] [day]")

  let tiles = tiling(size: (0.37cm, 0.37cm))[
    #place(circle(radius: 0.01cm, fill: black))
  ]

  let date_text = {
    grid(
      columns: (30pt, 1fr),
      rows: (20pt, 1fr),
      text(size: 17pt)[#day.display("[month repr:short]") #label(str(p))], [],
      text(size: 12pt)[#day.display("[day padding:none]")], text(size: 12pt)[#day.display("[weekday repr:short]")],
    )
  }

  grid(
    columns: (60pt, 2fr, 90pt),
    rows: (50pt, 1fr),
    gutter: 1pt,
    strong(date_text), [], calendar_mini(year, day.month()),
    grid.cell(colspan: 3, rect(fill: tiles, width: 100%, height: 100%)),
  )

  colbreak()
}


#let current_month_state = state("current_month", 1)

#let thumb-index = context {
  let months = ()
  for month in range(1, 13) [
    #let day = datetime(
      year: year,
      month: month,
      day: 1,
    )
    #let p = day.display("[month repr:long]")
    #let content = link(label(str(p)))[#day.display("[month repr:short]")]
    #months.push(content)
  ]
  let current_month = current_month_state.get()
  set table(
    fill: (x, y) => if x == current_month - 1 {
      gray.lighten(10%)
    } else {
      gray.lighten(90%)
    },
    align: right,
  )
  show table.cell.where(x: current_month - 1): strong
  place(right + horizon, rotate(90deg, reflow: true, table(
    stroke: none,
    columns: range(1, 13).map(x => 45pt),
    align: center,
    ..months,
  )))
}

#let year_page = {
  for month in range(1, 13) [
    #calendar_table(year, month)
  ]

  set page(columns: 2, foreground: thumb-index)
  let month_date = datetime(
    year: year,
    month: 1,
    day: 1,
  )
  for page in range(0, 366) [
    #let days = duration(days: page)
    #let current_date = month_date + days
    #if current_date.year() == year {
      current_month_state.update(current_date.month())
      date_page(current_date)
    }
  ]
}

#year_page

