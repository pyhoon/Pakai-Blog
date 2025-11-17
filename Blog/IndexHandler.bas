B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.3
@EndOfDesignText@
'Handler class
Sub Class_Globals
	Private App As EndsMeet
	Private Request As ServletRequest
	Private Response As ServletResponse
End Sub

Public Sub Initialize
	App = Main.App
End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	Request = req
	Response = resp
	Dim path As String = Request.RequestURI
	If path = "/" Then
		RenderPage
	End If
End Sub

Private Sub RenderPage
	Dim main1 As MainView
	main1.Initialize
	main1.LoadContent(ContentContainer)
	Dim page1 As Tag = main1.Render

	Dim body1 As Tag = page1.Child(1)
	Dim nav1 As Tag = body1.Child(0)
	Dim container1 As Tag = nav1.Child(0)
	Dim navbar1 As Tag = container1.Child(3)
	Dim ulist1 As Tag = navbar1.Child(0)
	
	Dim list1 As Tag = Li.cls("nav-item d-block d-lg-block").up(ulist1)
	Dim anchor1 As Tag = Anchor.href("/categories").up(list1)
	anchor1.cls("nav-link")
	anchor1.text("Categories")

	Dim list2 As Tag = Li.cls("nav-item d-block d-lg-block").up(ulist1)
	Dim anchor2 As Tag = Anchor.href("/articles").up(list2)
	anchor2.cls("nav-link")
	anchor2.text("Articles")
	
	Dim doc As Document
	doc.Initialize
	doc.AppendDocType
	doc.Append(page1.build)
	App.WriteHtml2(Response, doc.ToString, App.ctx)
End Sub

Private Sub ContentContainer As Tag
	Dim content1 As Tag = Div.cls("row mt-3 text-center align-items-center justify-content-center")
	Dim col1 As Tag = Div.cls("col-md-12 col-lg-6").up(content1)
	Dim container1 As Tag = Div.up(col1)
	container1.hxGet("/api/articles/list")
	container1.hxTrigger("load")
	container1.text("Loading...")

	Return content1
End Sub