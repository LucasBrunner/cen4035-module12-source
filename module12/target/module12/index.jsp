<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="util.*"%>
<%@ page import="java.time.LocalDateTime"%>
<%@ page import="java.time.format.DateTimeFormatter"%>

<!DOCTYPE html>
<html lang="en">
<head>
  <script src="scripts/samplescript.js"></script>
  <link rel="stylesheet" type="text/css" href="css/listdotcom.css" >

  <title>List.com (built using maven)</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Welcome to List.com, your (soon to be) one stop shop for keeping track of stuff.">
</head>

<body class="light-mode" onload="onPageLoad()">
  <header>
    <div id="header-content">
      <div id="header-checkbox"></div>
      <h1>List.com!</h1>
      <div class="button" id="lightmodeToggleButton" onclick="toggleLightmode()">Dark Mode</div>
    </div>
  </header>
  <div id="content" class="page-wrap">
    <form id="main" action="index.jsp"> <!-- method="get" -->
      
      <%
        String driver = "com.mysql.cj.jdbc.Driver";
        String url = "jdbc:mysql://localhost:3306/listdotcom?useSSL=false";
        String username = "java";
        String password = "java";
    
        Class.forName(driver);
        Connection con = DriverManager.getConnection(url, username, password);
        PreparedStatement listContents = null;
        ResultSet results = null;

        try {

          if (request.getParameter("new_list") != null) {
          %>
            <button class="top_button" type="submit" name="list_overview" value="list_overview">Cancel</button>
            <table>
              <tr>
                <th>List Name</th>
                <td>
                  <input type="text" name="list_name" value="New List">
                </td>
              </tr>
            </table>
            <button class="bottom_button" type="submit" name="create_list" value="create_list">Create</button>
          <%
          } else if (request.getParameter("new_item") != null) {
          %>
          <data class="new_item_list">
            <%
              out.print(request.getParameter("new_item"));
            %>
          </data>
          <button class="top_button" type="submit" name="view_list" value="view_list">Cancel</button>
          <table>
            <tr>
              <th>Name</th>
              <td>
                <input type="text" name="name" value="New Item">
              </td>
            </tr>
            <tr>
              <th>Start</th>
              <td>
                <input type="datetime-local" name="start">
              </td>
            </tr>
            <tr>
              <th>End</th>
              <td>
                <input type="datetime-local" name="end">
              </td>
            </tr>
            <tr>
              <th>Location</th>
              <td>
                <input type="text" name="location">
              </td>
            </tr>
            <tr>
              <th>Description</th>
              <td>
                <input type="text" name="content">
              </td>
            </tr>
          </table>
          <button id="create_item" class="bottom_button" type="submit" name="create_item">Create</button>
          <%
          } else if (
            request.getParameter("view_list") != null
            || request.getParameter("delete_item") != null
            || request.getParameter("save_item") != null
            || request.getParameter("create_item") != null
          ) {
            String parameter = "";

            if (request.getParameter("delete_item") != null) {
              parameter = request.getParameter("delete_item");
              listContents = con.prepareStatement("DELETE FROM to_do_item WHERE ID = ?;");
              listContents.setInt(1, Integer.parseInt(parameter.split("-")[0]));
              listContents.executeUpdate();
              parameter = parameter.split("-")[1];

            } else if (request.getParameter("save_item") != null) {
              parameter = request.getParameter("save_item");
              listContents = con.prepareStatement("UPDATE to_do_item SET Name = ?, Location = ?, Start = ?, End = ?, Content = ? WHERE ID = ? ORDER BY Start, End;");

              listContents.setString(1, request.getParameter("name"));
              listContents.setString(2, request.getParameter("location"));
              if (request.getParameter("start") == "") {
                listContents.setNull(3, java.sql.Types.TIMESTAMP); 
              } else {
                listContents.setTimestamp(3, Timestamp.valueOf(LocalDateTime.parse(request.getParameter("start"))));                
              }
              if (request.getParameter("end") == "") {
                listContents.setNull(4, java.sql.Types.TIMESTAMP); 
              } else {
                listContents.setTimestamp(4, Timestamp.valueOf(LocalDateTime.parse(request.getParameter("end"))));
              }
              listContents.setString(5, request.getParameter("content"));
              listContents.setInt(6, Integer.parseInt(parameter.split("-")[0]));
              listContents.executeUpdate();

              parameter = parameter.split("-")[1];

            } else if (request.getParameter("create_item") != null) {
              parameter = request.getParameter("create_item");
              listContents = con.prepareStatement("INSERT INTO to_do_item (Name, Location, Start, End, Content, List) VALUES (?, ?, ?, ?, ?, ?);");
              
              listContents.setString(1, request.getParameter("name"));
              listContents.setString(2, request.getParameter("location"));
              if (request.getParameter("start") == "") {
                listContents.setNull(3, java.sql.Types.TIMESTAMP); 
              } else {
                listContents.setTimestamp(3, Timestamp.valueOf(LocalDateTime.parse(request.getParameter("start"))));                
              }
              if (request.getParameter("end") == "") {
                listContents.setNull(4, java.sql.Types.TIMESTAMP); 
              } else {
                listContents.setTimestamp(4, Timestamp.valueOf(LocalDateTime.parse(request.getParameter("end"))));
              }
              listContents.setString(5, request.getParameter("content"));
              listContents.setInt(6, Integer.parseInt(parameter));
              listContents.executeUpdate();
            } else {
              parameter = request.getParameter("view_list");
            }

            listContents = con.prepareStatement("SELECT Name, ID, List, Start, End, Location, Content FROM to_do_item WHERE List = ?;");
            listContents.setInt(1, Integer.parseInt(parameter));
            results = listContents.executeQuery();
          %>
          <data class="list_id">
            <%
              out.println(Integer.parseInt(parameter));
            %>
          </data>
            <button class="top_button" type="submit" name="list_overview" value="list_overview">Return to List Overview</button>
            <table>
              <tr>
                <th></th>
                <th></th>
                <th>Name</th>
                <th>Start</th>
                <th>End</th>
                <th>Location</th>
                <th>Description</th>
              </tr>
            <%
              while (results.next()) {
              %>
                <tr class="item_data_row">
                  <td>
                    <button class="item_edit_button" type="submit" name="edit_item">Edit Item</button>
                  </td>
                  <td>
                    <button class="item_delete_button" type="submit" name="delete_item">Delete Item</button>
                  </td>
                  <td>
                    <%
                      out.println(results.getString(1));
                    %>
                  </td>
                  <td class="item_id">
                    <%
                      out.println(results.getInt(2));
                    %>
                  </td>
                  <td class="list_id">
                    <%
                      out.println(results.getInt(3));
                    %>
                  </td>
                  <td>
                    <%
                      Timestamp start = results.getTimestamp(4);
                      if (start != null) {
                        out.println(start);
                      } else {
                        out.println("-");
                      }
                    %>
                  </td>
                  <td>
                    <%
                      Timestamp end = results.getTimestamp(5);
                      if (end != null) {
                        out.println(end);
                      } else {
                        out.println("-");
                      }
                    %>
                  </td>
                  <td>
                    <%
                      String location = results.getString(6);
                      if (location != null) {
                        out.println(location);
                      } else {
                        out.println("-");
                      }
                    %>
                  </td>
                  <td>
                    <%
                      String description = results.getString(7);
                      if (description != null) {
                        out.println(description);
                      } else {
                        out.println("-");
                      }
                    %>
                  </td>
                </tr>
              <%
              } 
            %>
            </table>  
            <button class="bottom_button" type="submit" name="new_item">Create New Item</button>
          <%
          } else if (request.getParameter("edit_item") != null) {
            listContents = con.prepareStatement("SELECT Name, ID, List, Start, End, Location, Content FROM to_do_item WHERE ID = ?;");
            listContents.setInt(1, Integer.parseInt(request.getParameter("edit_item")));
            results = listContents.executeQuery();
          %>
            <button class="top_button" type="submit" name="view_list">Cancel</button>
          <%
            if (results.next()) {
            %>
              <data class="edit_item_id">
            <%
              out.print(results.getInt(2));
            %>
              </data>
              <data class="edit_item_list">
            <%
              out.print(results.getInt(3));
            %>
              </data>
              <table>
                <tr>
                  <th>Name</th>
                  <td class="edit_item_cell">
                    <%
                      out.print(results.getString(1));
                    %>
                    <input type="text" name="name">
                  </td>
                </tr>
                <tr>
                  <th>Start</th>
                  <td class="edit_item_cell">
                    <%
                      Timestamp start = results.getTimestamp(4);
                      if (start != null) {
                        out.println(start.toLocalDateTime().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
                      } else {
                        out.println("");
                      }
                    %>
                    <input type="datetime-local" name="start">
                  </td>
                </tr>
                <tr>
                  <th>End</th>
                  <td class="edit_item_cell">
                    <%
                      Timestamp end = results.getTimestamp(5);
                      if (end != null) {
                        out.println(end.toLocalDateTime().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
                      } else {
                        out.println("");
                      }
                    %>
                    <input type="datetime-local" name="end">
                  </td>
                </tr>
                <tr>
                  <th>Location</th>
                  <td class="edit_item_cell">
                    <%
                      String location = results.getString(6);
                      if (location != null) {
                        out.println(location);
                      } else {
                        out.println("");
                      }
                    %>
                    <input type="text" name="location">
                  </td>
                </tr>
                <tr>
                  <th>Description</th>
                  <td class="edit_item_cell">
                    <%
                      String description = results.getString(7);
                      if (description != null) {
                        out.println(description);
                      } else {
                        out.println("");
                      }
                    %>
                    <input type="text" name="content">
                  </td>
                </tr>
              </table>
              <button class="bottom_button" type="submit" name="save_item">Save Changes</button>
            <%
            }
          } else {
            if (request.getParameter("delete_list") != null) {
              listContents = con.prepareStatement("DELETE FROM to_do_list WHERE ID = ?;");
              listContents.setInt(1, Integer.parseInt(request.getParameter("delete_list")));
              listContents.executeUpdate();
            } else if (request.getParameter("create_list") != null) {
              listContents = con.prepareStatement("INSERT INTO to_do_list (Name) VALUES (?);");
              listContents.setString(1, request.getParameter("list_name"));
              listContents.executeUpdate();
            }

            listContents = con.prepareStatement("SELECT Name, ID FROM to_do_list;");
            results = listContents.executeQuery();

          %>
            <table>
            <%
              while (results.next()) {
              %>
                <tr class="list_data_row">
                  <td>
                    <button class="list_view_button" type="submit" name="view_list">View List</button>
                  </td>
                  <td>
                    <button class="list_delete_button" type="submit" name="delete_list">Delete List</button>
                  </td>
                  <td>
                    <%
                      out.println(results.getString(1));
                    %>
                  </td>
                  <td class="list_id">
                    <%
                      out.println(results.getInt(2));
                    %>
                  </td>
                </tr>
              <%
              } 
            %>
            </table>  
            <button class="bottom_button" type="submit" name="new_list" value="new_list">Create New List</button>
          <%
          }
        } catch(Exception e) {
          throw e;
        }
        con.close();
      %>
      
    </form>
  </div>
  <footer>
    <i>Copyright &copy; 2022 LucasBrunner</i><br>
    <a href="">Lucas@Brunner.com</a><br>
    <p class="appendModifiedDate">This page was last modified on </p>
  </footer>

</body>

</html>
</html>