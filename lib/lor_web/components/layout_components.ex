defmodule LorWeb.LayoutComponents do
  @moduledoc false
  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: LorWeb.Endpoint,
    router: LorWeb.Router,
    statics: LorWeb.static_paths()

  alias LorWeb.CoreComponents, as: Core
  alias LorWeb.PetalComponents, as: PC
  alias Phoenix.LiveView.JS

  attr :game_version, :string, required: true
  slot :inner_block
  slot :sidebar_block

  def skeleton(assigns) do
    ~H"""
    <main>
      <!-- Site header -->
      <header class="fixed z-40 w-full">
        <!-- background -->
        <div
          class="absolute inset-0 -z-10 border-b border-slate-200 bg-white bg-opacity-70 backdrop-blur supports-backdrop-blur:bg-white/95 dark:border-slate-50/[0.06] dark:bg-slate-900/75 lg:border-slate-900/10"
          aria-hidden="true"
        />
        <div class="max-w-[90rem] mx-auto px-4 sm:px-6">
          <div class="flex h-16 items-center justify-between">
            <!-- Site branding -->
            <div class="grow">
              <div class="flex items-center">
                <.link navigate={~p"/"}>
                  <div class="flex items-center">
                    <img class="h-16" src={~p"/images/logo.svg"} />
                    <h1 class="ml-2 hidden text-3xl font-bold lg:inline">LOR</h1>
                  </div>
                </.link>
              </div>
            </div>
            <!-- Navigation -->
            <nav aria-label="User menu" class="flex items-center">
              <div class="z-10 flex w-full items-center justify-end gap-1 text-violet-500 lg:gap-2">
                <div class="flex gap-1 md:gap-2">
                  <PC.icon_button
                    link_type="a"
                    target="_blank"
                    to="https://discord.gg/CvU8HqmMyd"
                    class="rounded-lg p-2.5 text-sm text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-4 focus:ring-gray-200 dark:text-gray-400 dark:hover:bg-gray-700 dark:focus:ring-gray-700"
                  >
                    <Core.icon name="svg-discord" class="h-5 w-5" />
                  </PC.icon_button>
                  <PC.icon_button
                    link_type="a"
                    target="_blank"
                    to="https://github.com/mrdotb/leagueofreplays"
                    class="rounded-lg p-2.5 text-sm text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-4 focus:ring-gray-200 dark:text-gray-400 dark:hover:bg-gray-700 dark:focus:ring-gray-700"
                  >
                    <Core.icon name="svg-github" class="h-5 w-5" />
                  </PC.icon_button>
                  <.color_scheme_switch id="nav-scheme-switch" />
                </div>
              </div>
            </nav>
          </div>
        </div>
      </header>
      <!-- Mobile hamburger + Breadcrumbs -->
      <div class="top-[64px] fixed z-30 flex w-full items-center border-t border-slate-200 bg-white bg-opacity-70 p-4 backdrop-blur supports-backdrop-blur:bg-white/95 dark:border-slate-50/[0.06] dark:bg-slate-900/75 md:hidden lg:border-slate-900/10">
        <!-- Hamburger button -->
        <button
          id="hamburger"
          phx-click={show_sidebar()}
          aria-controls="sidebar"
          aria-expanded="false"
        >
          <span class="sr-only">Menu</span>
          <Core.icon name="hero-bars-3" class="h-6 w-6 fill-slate-600 dark:fill-slate-400" />
        </button>
        <!-- TODO Breadcrumbs -->
      </div>
      <!-- Page content -->
      <main class="grow px-5">
        <section class="relative">
          <div class="max-w-[90rem] mx-auto pt-14 md:pt-0">
            <!-- Main content -->
            <div>
              <!-- Backdrop for responsive sidebar nav-->
              <div
                id="sidebar-backdrop"
                class="fixed inset-0 z-10 hidden bg-slate-900 bg-opacity-20 transition-opacity md:hidden"
              />
              <!-- Sidebar -->
              <aside
                id="sidebar"
                class="fixed top-0 bottom-0 left-0 z-30 hidden h-screen w-64 border-r border-slate-200 dark:border-slate-800 dark:bg-slate-900 md:!opacity-100 md:!block md:left-auto md:shrink-0"
                phx-click-away={hide_sidebar()}
              >
                <!-- Sidebar Gradient bg on light scheme only -->
                <div
                  class="-left-[9999px] pointer-events-none absolute inset-0 -z-10 bg-gradient-to-b from-slate-50 to-white dark:hidden"
                  aria-hidden="true"
                />
                <div class="fixed top-0 bottom-0 mt-16 flex w-64 flex-col justify-between overflow-y-auto px-4 sm:px-6 md:pr-8 md:pl-0">
                  <div class="pt-8 pb-8 md:pt-12">
                    <nav>
                      <%= render_slot(@sidebar_block) %>
                    </nav>
                  </div>

                  <div>
                    <div class="px-2 py-4 text-center text-lg">
                      <span>Patch: <%= @game_version %></span>
                    </div>
                  </div>
                </div>
              </aside>
              <!-- Page container -->
              <div class="md:grow md:pl-64 lg:pr-6 xl:pr-0">
                <div class="pt-24 pb-8 md:pt-28 md:pl-6 lg:pl-12">
                  <!-- Main area -->
                  <div class="w-full">
                    <!-- Article content -->
                    <div>
                      <div>
                        <%= render_slot(@inner_block) %>
                      </div>
                      <footer class="mt-12 text-sm leading-6">
                        <div class="justify-between border-t border-slate-200 pt-10 pb-28 text-slate-500 dark:border-slate-200/5 sm:flex">
                          <div class="mb-6 sm:mb-0 sm:flex">
                            <p class="text-xs">
                              leagueofreplays.co is not endorsed by Riot Games and does not reflect the views or opinions of Riot Games or anyone officially involved in producing or managing Riot Games properties. Riot Games and all associated properties are trademarks or registered trademarks of Riot Games, Inc
                            </p>
                            <div class="flex items-center sm:ml-4 sm:border-l sm:border-slate-200 sm:pl-4 sm:dark:border-slate-200/5">
                              <a
                                class="whitespace-nowrap hover:text-slate-900 dark:hover:text-slate-400"
                                href="/privacy"
                              >
                                Privacy Policy
                              </a>
                            </div>
                          </div>
                        </div>
                      </footer>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>
      </main>
    </main>
    """
  end

  @doc """
  A button that switches between light and dark modes.
  Pairs with css-theme-switch.js

  ## Examples
      <.color_scheme_switch_js id="nav-theme-switch" />
  """
  attr :id, :string, required: true

  def color_scheme_switch(assigns) do
    ~H"""
    <button
      phx-hook="ColorSchemeHook"
      type="button"
      id={@id}
      class="color-scheme rounded-lg p-2.5 text-sm text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-4 focus:ring-gray-200 dark:text-gray-400 dark:hover:bg-gray-700 dark:focus:ring-gray-700"
    >
      <Core.icon name="hero-moon-solid" class="color-scheme-dark-icon hidden h-5 w-5" />
      <Core.icon name="hero-sun-solid" class="color-scheme-light-icon hidden h-5 w-5" />
    </button>
    """
  end

  @doc """
  Used for switching dark/light color schemes.

  This needs to be inlined in the <head> because it will set a class on the document, which affects all "dark" prefixed classed (eg. dark:text-white). If you do this in the body or a separate javascript file then when in dark mode, the page will flash in light mode first before switching to dark mode.

  Utilized by `color-scheme-hook.js`.

  ## Examples
      <.color_scheme_switch_js />
  """
  def color_scheme_switch_js(assigns) do
    ~H"""
    <script>
      window.applyScheme = function(scheme) {
        if (scheme === "light") {
          document.documentElement.classList.remove('dark')
          document
            .querySelectorAll(".color-scheme-dark-icon")
            .forEach((el) => el.classList.remove("hidden"));
          document
            .querySelectorAll(".color-scheme-light-icon")
            .forEach((el) => el.classList.add("hidden"));
          localStorage.scheme = 'light'
        } else {
          document.documentElement.classList.add('dark')
          document
            .querySelectorAll(".color-scheme-dark-icon")
            .forEach((el) => el.classList.add("hidden"));
          document
            .querySelectorAll(".color-scheme-light-icon")
            .forEach((el) => el.classList.remove("hidden"));
          localStorage.scheme = 'dark'
        }
      };

      window.toggleScheme = function () {
        if (document.documentElement.classList.contains('dark')) {
          applyScheme("light")
        } else {
          applyScheme("dark")
        }
      }

      window.initScheme = function() {
        if (localStorage.scheme === 'dark' || (!('scheme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
          applyScheme("dark")
        } else {
          applyScheme("light")
        }
      }

      try {
        initScheme()
      } catch (_) {}
    </script>
    """
  end

  ## JS Commands

  def show_sidebar(js \\ %JS{}) do
    js
    |> JS.show(
      to: "#sidebar",
      transition: {
        "transition ease-out duration-200 transform",
        "opacity-0 -translate-x-full",
        "opacity-100 translate-x-0"
      }
    )
    |> JS.show(
      to: "#sidebar-backdrop",
      transition: {
        "transition ease-out duration-200",
        "opacity-0",
        "opacity-100"
      }
    )
    |> JS.set_attribute({"aria-expanded", "true"}, to: "#hamburger")
  end

  def hide_sidebar(js \\ %JS{}) do
    js
    |> JS.hide(
      to: "#sidebar",
      transition: {
        "transition ease-out duration-200 transform",
        "opacity-100",
        "opacity-0"
      }
    )
    |> JS.hide(
      to: "#sidebar-backdrop",
      transition: {
        "transition ease-out duration-100",
        "opacity-100",
        "opacity-0"
      }
    )
    |> JS.set_attribute({"aria-expanded", "false"}, to: "#hamburger")
  end
end
