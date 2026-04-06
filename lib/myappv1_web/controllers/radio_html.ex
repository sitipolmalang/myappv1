defmodule Myappv1Web.RadioHTML do
  use Myappv1Web, :html

  embed_templates "radio_html/*"

  @doc """
  Renders a radio form.

  The form is defined in the template at
  radio_html/radio_form.html.heex
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :return_to, :string, default: nil

  def radio_form(assigns)
end
