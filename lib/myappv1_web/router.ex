defmodule Myappv1Web.Router do
  use Myappv1Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Myappv1Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Myappv1Web do
    pipe_through :browser

    get "/", PageController, :home

    # Routes for the Radio resource using LiveView
    live "/radios", RadioLive.Index, :index
    # live "/radios/:id", RadioLive.Show, :show
    live "/radios/new", RadioLive.Form, :new
    live "/radios/:id/edit", RadioLive.Form, :edit
    # Routes for the Radio resource using traditional controllers
    post "/radios", RadioController, :create
    put "/radios/:id", RadioController, :update
    delete "/radios/:id", RadioController, :delete
    get "/radios/:id", RadioController, :show

    # Routes for the Category resource using LiveView
    live "/categories", CategoryLive.Index, :index
    live "/categories/new", CategoryLive.Form, :new
    live "/categories/:id", CategoryLive.Show, :show
    live "/categories/:id/edit", CategoryLive.Form, :edit

    # Routes for the Tag resource using LiveView
    live "/tags", TagLive.Index, :index
    live "/tags/new", TagLive.Form, :new
    live "/tags/:id", TagLive.Show, :show
    live "/tags/:id/edit", TagLive.Form, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", Myappv1Web do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:myappv1, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: Myappv1Web.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
