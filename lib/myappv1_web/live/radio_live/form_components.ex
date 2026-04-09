defmodule Myappv1Web.RadioLive.FormComponents do
  use Myappv1Web, :html

  alias Myappv1Web.RadioLive.UploadHelpers

  attr :form, :any, required: true
  attr :radio, :map, required: true
  attr :uploads, :map, required: true
  attr :category_options, :list, required: true
  attr :tag_options, :list, required: true
  attr :cancel_path, :string, required: true

  def radio_form(assigns) do
    ~H"""
    <.form for={@form} id="radio-form" phx-change="validate" phx-submit="save">
      <.input field={@form[:name]} type="text" label="Name" />
      <.input field={@form[:code]} type="text" label="Code" />
      <.input field={@form[:category_id]} type="select" label="Category" options={@category_options} />
      <.input field={@form[:tag_ids]} type="select" label="Tags" multiple options={@tag_options} />
      <div class="space-y-6 pt-2">
        <p class="text-sm font-medium text-zinc-700 dark:text-zinc-300">Images (optional, max 3)</p>
        
        <div class="grid gap-6 sm:grid-cols-3">
          <%= for slot <- 1..3 do %>
            <div class="rounded-xl border border-zinc-200/80 bg-zinc-50/50 p-4 dark:border-zinc-700 dark:bg-zinc-900/40">
              <p class="mb-3 text-xs font-semibold uppercase tracking-wide text-zinc-500 dark:text-zinc-400">
                Slot {slot}
              </p>
              
              <%= if ri = UploadHelpers.radio_image_at(UploadHelpers.radio_images_list(@radio), slot) do %>
                <div class="mb-3 overflow-hidden rounded-lg border border-zinc-200 dark:border-zinc-600">
                  <img
                    src={UploadHelpers.radio_image_url(ri)}
                    alt=""
                    class="h-32 w-full object-cover"
                  />
                </div>
                
                <.button
                  type="button"
                  class="mb-3 w-full border border-zinc-300 bg-white text-zinc-800 hover:bg-zinc-50 dark:border-zinc-600 dark:bg-zinc-800 dark:text-zinc-100 dark:hover:bg-zinc-700"
                  phx-click="remove_image"
                  phx-value-slot={slot}
                  id={"remove-image-slot-#{slot}"}
                >
                  Remove image
                </.button>
              <% end %>
              
              <label class="block text-xs text-zinc-600 dark:text-zinc-400">
                <.live_file_input
                  upload={Map.get(@uploads, :"radio_slot_#{slot}")}
                  class="block w-full text-sm"
                />
              </label>
            </div>
          <% end %>
        </div>
        
        <p class="text-xs text-zinc-500 dark:text-zinc-400">
          JPG, PNG, GIF, or WebP. Up to 2 MB per image.
        </p>
      </div>
      
      <footer>
        <.button phx-disable-with="Saving..." variant="primary">Save Radio</.button>
        <.button navigate={@cancel_path}>Cancel</.button>
      </footer>
    </.form>
    """
  end
end
