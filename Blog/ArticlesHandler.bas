B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
'Handler class
Sub Class_Globals
	Private DB As MiniORM
	Private App As EndsMeet
	Private Method As String
	Private Request As ServletRequest
	Private Response As ServletResponse
End Sub

Public Sub Initialize
	App = Main.App
	DB.Initialize(Main.DBType, Null)
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	Method = req.Method
	Log($"${Request.Method}: ${Request.RequestURI}"$)
	Dim path As String = req.RequestURI
	If path = "/" Then
		RenderPage
	Else If path = "/api/articles/table" Then
		HandleTable
	Else If path = "/api/articles/add" Then
		HandleAddModal
	Else If path.StartsWith("/api/articles/edit/") Then
		HandleEditModal
	Else If path.StartsWith("/api/articles/delete/") Then
		HandleDeleteModal
	Else
		HandleArticles
	End If
End Sub

Private Sub RenderPage
	Dim main1 As MainView
	main1.Initialize
	main1.LoadContent(ContentContainer)
	main1.LoadModal(ModalContainer)
	main1.LoadToast(ToastContainer)
	Dim page1 As Tag = main1.Render
	Dim doc As Document
	doc.Initialize
	doc.AppendDocType
	doc.Append(page1.build)
	App.WriteHtml2(Response, doc.ToString, App.ctx)
End Sub

Private Sub ContentContainer As Tag
	Dim content1 As Tag = Div.cls("row mt-3 text-center align-items-center justify-content-center")
	Dim col1 As Tag = Div.cls("col-md-12 col-lg-6").up(content1)
	Dim form1 As Tag = Form.cls("form mb-3").action("").up(col1)
	
	Dim row1 As Tag = Div.cls("row").up(form1)
	Dim col2 As Tag = Div.cls("col-md-6 col-lg-6 text-start").up(row1)
	H3.cls("text-uppercase").text("Title").up(col2)
	
	Dim div1 As Tag = Div.cls("col-md-6 col-lg-6").up(row1)
	Dim div2 As Tag = Div.cls("text-end mt-2").up(div1)

	Dim anchor1 As Tag = Anchor.up(div2)
	anchor1.hrefOf("$SERVER_URL$")
	anchor1.cls("btn btn-primary me-2")
	anchor1.add(Icon.cls("bi bi-house me-2"))
	anchor1.text("Home")

	Dim button2 As Tag = Button.up(div2)
	button2.cls("btn btn-success ml-2")
	button2.hxGet("/api/articles/add")
	button2.hxTarget("#modal-content")
	button2.hxTrigger("click")
	button2.data("bs-toggle", "modal")
	button2.data("bs-target", "#modal-container")
	button2.add(Icon.cls("bi bi-plus-lg me-2"))
	button2.text("Add Articles")

	Dim container1 As Tag = Div.up(col1)
	container1.id("articles-container")
	container1.hxGet("/api/articles/table")
	container1.hxTrigger("load")
	container1.text("Loading...")

	Return content1
End Sub

Private Sub ModalContainer As Tag
	Dim modal1 As Tag = Div.id("modal-container")
	modal1.cls("modal fade")
	modal1.attr("tabindex", "-1")
	modal1.aria("hidden", "true")
	Dim modalDialog As Tag = Div.up(modal1).cls("modal-dialog modal-dialog-centered")
	Div.cls("modal-content").id("modal-content").up(modalDialog)
	Return modal1
End Sub

Private Sub ToastContainer As Tag
	Dim div1 As Tag = Div.cls("position-fixed end-0 p-3")
	div1.sty("z-index: 2000")
	div1.sty("bottom: 0%")
	Dim toast1 As Tag = Div.id("toast-container").up(div1)
	toast1.cls("toast align-items-center text-bg-success border-0")
	toast1.attr("role", "alert")
	Dim div2 As Tag = Div.cls("d-flex").up(toast1)
	Dim div3 As Tag = Div.cls("toast-body").id("toast-body").up(div2)
	div3.text("Operation successful!")
	Dim button1 As Tag = Button.typeOf("button").up(div2)
	button1.cls("btn-close btn-close-white me-2 m-auto")
	button1.data("bs-dismiss", "toast")
	Return div1
End Sub

' Return table HTML
Private Sub HandleTable
	App.WriteHtml(Response, CreateArticlesTable.Build)
End Sub

' Add modal
Private Sub HandleAddModal
	Dim form1 As Tag = Form.init
	form1.hxPost("/api/articles")
	form1.hxTarget("#modal-messages")
	form1.hxSwap("innerHTML")
	
	Dim modalHeader As Tag = Div.cls("modal-header").up(form1)
	H5.cls("modal-title").text("Add Articles").up(modalHeader)
	Button.typeOf("button").cls("btn-close").data("bs-dismiss", "modal").up(modalHeader)

	Dim modalBody As Tag = Div.cls("modal-body").up(form1)
	Div.id("modal-messages").up(modalBody)'.hxSwapOob("true")
	
	Dim group1 As Tag = Div.cls("form-group").up(modalBody)
	Label.forId("category1").text("Category ").up(group1).add(Span.cls("text-danger").text("*"))
	Dim select1 As Tag = CreateCategoriesDropdown(-1)
	select1.id("category1")
	select1.name("category")
	select1.up(group1)
	
	Dim group1 As Tag = modalBody.add(Div.cls("form-group"))
	Label.forId("title").text("Title ").up(group1).add(Span.cls("text-danger").text("*"))
	Input.typeOf("text").up(group1).id("title").name("title").cls("form-control").attr3("required")

	Dim group2 As Tag = modalBody.add(Div.cls("form-group"))
	Label.forId("body").text("Body ").up(group2).add(Span.cls("text-danger").text("*"))
	Textarea.rows("3").up(group2).id("body").name("body").cls("form-control").attr3("required")

	Dim group3 As Tag = modalBody.add(Div.cls("form-group"))
	Label.forId("status").text("Status ").up(group3).add(Span.cls("text-danger").text("*"))
	Dim select1 As Tag = Dropdown.up(group3).id("status").name("status").cls("form-select").attr3("required")
	Option.valueOf("0").text("Draft").up(select1)
	Option.valueOf("1").text("Published").up(select1)

	Dim modalFooter As Tag = Div.cls("modal-footer").up(form1)
	Button.typeOf("submit").cls("btn btn-success px-3").text("Create").up(modalFooter)
	Button.typeOf("button").cls("btn btn-secondary px-3").data("bs-dismiss", "modal").text("Cancel").up(modalFooter)

	App.WriteHtml(Response, form1.Build)
End Sub

' Edit modal
Private Sub HandleEditModal
	Dim id As String = Request.RequestURI.SubString("/api/articles/edit/".Length)
	Dim form1 As Tag = Form.init
	form1.hxPut($"/api/articles"$)
	form1.hxTarget("#modal-messages")
	form1.hxSwap("innerHTML")
		
	DB.SQL = Main.DBOpen
	DB.Table = "tbl_articles"
	DB.Columns = Array("id", "article_name AS name")
	DB.WhereParam("id = ?", id)
	DB.Query
	If DB.Found Then
		Dim name As String = DB.First.Get("name")

		Dim modalHeader As Tag = Div.cls("modal-header").up(form1)
		H5.cls("modal-title").text("Edit Articles").up(modalHeader)
		Button.typeOf("button").cls("btn-close").data("bs-dismiss", "modal").up(modalHeader)
		
		Dim modalBody As Tag = Div.cls("modal-body").up(form1)
		Div.id("modal-messages").up(modalBody)
		Input.typeOf("hidden").up(modalBody).name("id").valueOf(id)
		
		Dim group1 As Tag = Div.cls("form-group").up(modalBody)
		Label.forId("name").text("Name ").up(group1).add(Span.cls("text-danger").text("*"))
		Input.typeOf("text").cls("form-control").id("name").name("name").valueOf(name).attr3("required").up(group1)

		Dim modalFooter As Tag = Div.cls("modal-footer").up(form1)
		Button.typeOf("submit").cls("btn btn-primary px-3").text("Update").up(modalFooter)
		Button.typeOf("button").cls("btn btn-secondary px-3").data("bs-dismiss", "modal").text("Cancel").up(modalFooter)
	End If
	DB.Close

	App.WriteHtml(Response, form1.Build)
End Sub

' Delete modal
Private Sub HandleDeleteModal
	Dim id As String = Request.RequestURI.SubString("/api/articles/delete/".Length)
	Dim form1 As Tag = Form.init
	form1.hxDelete($"/api/articles"$)
	form1.hxTarget("#modal-messages")
	form1.hxSwap("innerHTML")

	DB.SQL = Main.DBOpen
	DB.Table = "tbl_articles"
	DB.Columns = Array("id", "article_name AS name")
	DB.WhereParam("id = ?", id)
	DB.Query
	If DB.Found Then
		Dim name As String = DB.First.Get("name")

		Dim modalHeader As Tag = Div.cls("modal-header").up(form1)
		H5.cls("modal-title").text("Delete Articles").up(modalHeader)
		Button.typeOf("button").cls("btn-close").data("bs-dismiss", "modal").up(modalHeader)
		
		Dim modalBody As Tag = Div.cls("modal-body").up(form1)
		Div.id("modal-messages").up(modalBody)
		Input.typeOf("hidden").name("id").valueOf(id).up(modalBody)
		Paragraph.text($"Delete ${name}?"$).up(modalBody)

		Dim modalFooter As Tag = Div.cls("modal-footer").up(form1)
		Button.typeOf("submit").cls("btn btn-danger px-3").text("Delete").up(modalFooter)
		Button.typeOf("button").cls("btn btn-secondary px-3").data("bs-dismiss", "modal").text("Cancel").up(modalFooter)
	End If
	DB.Close

	App.WriteHtml(Response, form1.Build)
End Sub

' Handle CRUD operations
Private Sub HandleArticles
	Select Method
		Case "POST"
			' Create
			Dim article_title As String = Request.GetParameter("title")
			Dim article_body As String = Request.GetParameter("body")
			Dim article_status As String = Request.GetParameter("status")
			Dim category_id As Int = Request.GetParameter("category")
			
			If category_id < 1 Then
				ShowAlert("Please select a category for the Article.", "warning")
				Return
			End If			
			If article_title = "" Or article_title.Trim.Length < 2 Then
				ShowAlert("Article title must be at least 2 characters long.", "warning")
				Return
			End If
			If article_body = "" Then
				ShowAlert("Article body cannot be empty.", "warning")
				Return
			End If
			If article_status = "" Then
				ShowAlert("Please select a status for the Article.", "warning")
				Return
			End If
			Try
				DB.SQL = Main.DBOpen
				DB.Table = "tbl_articles"
				DB.Where = Array("article_title = ?")
				DB.Parameters = Array(article_title)
				DB.Query
				If DB.Found Then
					DB.Close
					ShowAlert("Article with same title already exists!", "warning")
					Return
				End If
			Catch
				Log(LastException)
				ShowAlert($"Database error: ${LastException.Message}"$, "danger")
			End Try

			' Insert new row
			Try
				DB.Reset
				DB.Columns = Array("article_title", "article_body", "article_status", "category_id")
				DB.Parameters = Array(article_title, article_body, article_status, category_id)
				DB.Save
				DB.Close
				ShowToast("Articles", "created", "Article created successfully!", "success")
			Catch
				ShowAlert($"Database error: ${LastException.Message}"$, "danger")
			End Try
		Case "PUT"
			' Update
			Dim id As Int = Request.GetParameter("id")
			Dim name As String = Request.GetParameter("name")
			DB.SQL = Main.DBOpen
			DB.Table = "tbl_articles"
			
			DB.Find(id)
			If DB.Found = False Then
				ShowAlert("Articles not found!", "warning")
				DB.Close
				Return
			End If

			DB.Reset
			DB.Where = Array("article_name = ?", "id <> ?")
			DB.Parameters = Array(name, id)
			DB.Query
			If DB.Found Then
				ShowAlert("Articles already exists!", "warning")
				DB.Close
				Return
			End If
			
			' Update row
			Try
				DB.Reset
				DB.Columns = Array("article_name", "modified_date")
				DB.Parameters = Array(name, Main.CurrentDateTime)
				DB.Id = id
				DB.Save
				DB.Close
				ShowToast("Articles", "updated", "Articles updated successfully!", "info")
			Catch
				ShowAlert($"Database error: ${LastException.Message}"$, "danger")
			End Try
		Case "DELETE"
			' Delete
			Dim id As Int = Request.GetParameter("id")
			DB.SQL = Main.DBOpen
			DB.Table = "tbl_articles"
			
			DB.Find(id)
			If DB.Found = False Then
				ShowAlert("Articles not found!", "warning")
				DB.Close
				Return
			End If
			
			DB.Table = "dbtable2" ' child table
			DB.WhereParam("article_id = ?", id)
			DB.Query
			If DB.Found Then
				ShowAlert("Cannot delete article with associated rows!", "warning")
				DB.Close
				Return
			End If

			' Delete row
			Try
				DB.Table = "tbl_articles"
				DB.Id = id
				DB.Delete
				DB.Close
				ShowToast("Articles", "deleted", "Articles deleted successfully!", "danger")
			Catch
				ShowAlert($"Database error: ${LastException.Message}"$, "danger")
			End Try
	End Select
End Sub

Private Sub CreateArticlesTable As Tag
	Dim table1 As Tag = HtmlTable.cls("table table-bordered table-hover rounded small")
	Dim thead1 As Tag = Thead.cls("table-light").up(table1)
	thead1.add(Th.sty("text-align: right; width: 50px").text("#"))
	thead1.add(Th.text("Title"))
	thead1.add(Th.sty("text-align: center; width: 120px").text("Actions"))
	Dim tbody1 As Tag = Tbody.init.up(table1)
	
	DB.SQL = Main.DBOpen
	DB.Table = "tbl_articles"
	DB.Columns = Array("id", "article_title AS title")
	DB.OrderBy = CreateMap("id": "")
	DB.Query
	For Each row As Map In DB.Results
		Dim tr1 As Tag = CreateArticlesRow(row)
		tr1.up(tbody1)
	Next
	DB.Close
	Return table1
End Sub

Private Sub CreateArticlesRow (data As Map) As Tag
	Dim id As Int = data.Get("id")
	Dim title As String = data.Get("title")

	Dim tr1 As Tag = Tr.init
	tr1.add(Td.cls("align-middle").sty("text-align: right").text(id))
	tr1.add(Td.cls("align-middle").text(title))
	
	Dim td3 As Tag = Td.cls("align-middle text-center px-1 py-1").up(tr1)

	Dim anchor1 As Tag = Anchor.cls("edit text-primary mx-2").up(td3)
	anchor1.hxGet($"/api/articles/edit/${id}"$)
	anchor1.hxTarget("#modal-content")
	anchor1.hxTrigger("click")
	anchor1.data("bs-toggle", "modal")
	anchor1.data("bs-target", "#modal-container")
	anchor1.add(Icon.cls("bi bi-pencil"))
	anchor1.attr("title", "Edit")
		
	Dim anchor2 As Tag = Anchor.cls("delete text-danger mx-2").up(td3)
	anchor2.hxGet($"/api/articles/delete/${id}"$)
	anchor2.hxTarget("#modal-content")
	anchor2.hxTrigger("click")
	anchor2.data("bs-toggle", "modal")
	anchor2.data("bs-target", "#modal-container")
	anchor2.add(Icon.cls("bi bi-trash3"))
	anchor2.attr("title", "Delete")
	
	Return tr1
End Sub

Private Sub ShowAlert (message As String, status As String)
	Dim div1 As Tag = Div.cls("alert alert-" & status).text(message)
	App.WriteHtml(Response, div1.Build)
End Sub

Private Sub ShowToast (entity As String, action As String, message As String, status As String)
	Dim div1 As Tag = Div.id("articles-container")
	div1.hxSwapOob("true")
	div1.add(CreateArticlesTable)

	Dim script1 As MiniJs
	script1.Initialize
	script1.AddCustomEventDispatch("entity:changed", _
	CreateMap( _
	"entity": entity, _
	"action": action, _
	"message": message, _
	"status": status))

	App.WriteHtml(Response, div1.Build & CRLF & script1.Generate)
End Sub

Private Sub CreateCategoriesDropdown (selected As Int) As Tag
	Dim select1 As Tag = Dropdown.cls("form-select")
	select1.attr3("required")
	'select1.hxGet("/api/categories/list")
	Option.valueOf("").text("Select Category").attr3(IIf(selected < 1, "selected", "")).attr3("disabled").up(select1)

	DB.SQL = Main.DBOpen
	DB.Table = "tbl_categories"
	DB.Columns = Array("id", "category_name AS name")
	DB.Query
	For Each row As Map In DB.Results
		Dim catid As Int = row.Get("id")
		Dim catname As String = row.Get("name")
		If catid = selected Then
			Option.valueOf(catid).attr3("selected").text(catname).up(select1)
		Else
			Option.valueOf(catid).text(catname).up(select1)
		End If
	Next
	DB.Close
	Return select1
End Sub