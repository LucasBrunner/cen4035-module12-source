let lightmodeStorageKey = "lightmode";
let lightmodeClass = "light-mode";
let darkmodeClass = "dark-mode";
let lightmodeToggleButton = "lightmodeToggleButton";

function onPageLoad() {
  checkLightmode();
  setModifiedDate();

  BuildListRows();
  BuildItemRows();
  BuildEditRows();
  BuildNewItem()
  
  allignBlanks();
}

function allignBlanks() {
  let TableCells = Array.from(document.getElementsByTagName("td"));
  TableCells.forEach(cell => {
    if (cell.textContent.trim() === "-") {
      cell.setAttribute("style", "text-align:center;");
    }
  })
}

function BuildNewItem() {
  listID = document.querySelector(".new_item_list")
  if (listID !== null) {
    listIDValue = listID.textContent.trim();
    listID.remove();

    document.querySelector(".top_button").setAttribute("value", listIDValue);
    document.querySelector(".bottom_button").setAttribute("value", listIDValue);
  }
}

function BuildEditRows() {
  let listID = document.querySelector(".edit_item_list");
  let itemID = document.querySelector(".edit_item_id");
  if (listID !== null && itemID !== null) {
    listIDValue = listID.textContent.trim();
    itemIDValue = itemID.textContent.trim();

    listID.remove();
    itemID.remove();
    
    document.querySelector(".top_button").setAttribute("value", listIDValue);
    document.querySelector(".bottom_button").setAttribute("value", itemIDValue + "-" + listIDValue);
  }

  let dataCells = Array.from(document.getElementsByClassName("edit_item_cell"));
  dataCells.forEach(cell => {
    let data = cell.childNodes[0].textContent.trim();
    if (
      cell.querySelector("input").getAttribute("type") === "datetime-local"
      && data != ""
    ) {
      cell.querySelector("input").value = parseDateTime(data).toISOString().slice(0, -1);
    } else {
      cell.querySelector("input").setAttribute("value", data);
    }
    cell.childNodes[0].textContent = "";
  });
}

// https://stackoverflow.com/a/35169689
function parseDateTime(s) {
  var b = s.split(/\D/);
  return new Date(b[0],b[1]-1,b[2],b[3],b[4],b[5])
}

function BuildListRows() {
  let rows = Array.from(document.getElementsByClassName("list_data_row"));
  rows.forEach(row => {
    let listID = row.querySelector(".list_id").textContent.trim();
    row.querySelector(".list_id").remove();

    row.querySelector(".list_view_button").setAttribute("value", listID);
    row.querySelector(".list_delete_button").setAttribute("value", listID);
  });
}

function BuildItemRows() {
  let listID = document.querySelector(".list_id");
  if (listID !== null) {
    listIDValue = listID.textContent.trim()
    document.querySelector(".bottom_button").value = listIDValue;
    listID.remove();
  }

  let rows = Array.from(document.getElementsByClassName("item_data_row"));
  rows.forEach(row => {
    let itemID = row.querySelector(".item_id").textContent.trim();
    let listID = row.querySelector(".list_id").textContent.trim();
    row.querySelector(".item_id").remove();
    row.querySelector(".list_id").remove();

    row.querySelector(".item_edit_button").setAttribute("value", itemID);
    row.querySelector(".item_delete_button").setAttribute("value", itemID + "-" + listID);
  });
}

function setModifiedDate() {
  let elements = Array.from(document.getElementsByClassName("appendModifiedDate"));
  elements.forEach(element => {
    element.textContent += new Date(document.lastModified).toISOString().substring(0, 10);
  });
}

function toggleLightmode() {
  if (document.body.className == lightmodeClass) {
    setLightmode(darkmodeClass);
    document.getElementById(lightmodeToggleButton).innerText = "Light Mode"
  } else {
    setLightmode(lightmodeClass);
    document.getElementById(lightmodeToggleButton).innerText = "Dark Mode"
  }
}

function setLightmode(lightmode) {
  document.body.className = lightmode;
  localStorage.setItem(lightmodeStorageKey, lightmode)
}

function checkLightmode() {
  let lightmodeState = localStorage.getItem(lightmodeStorageKey);
  if (lightmodeState !== null) {
    document.body.className = lightmodeState;

    // Toggle twice to get the correct button text.
    toggleLightmode();
    toggleLightmode();
  }
}