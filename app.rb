
require "pry" if ENV["RACK_ENV"] == "development"
require "rack/cors"
require 'sinatra'
require 'stripe'

use Rack::Cors do |config|
  config.allow do |allow|
    allow.origins '*'
    allow.resource '*',
      :headers => :any
  end
end

set :publishable_key, ENV['PUBLISHABLE_KEY']
set :secret_key, ENV['SECRET_KEY']

Stripe.api_key = settings.secret_key

get '/' do
  erb :index
end

post '/charge' do
  @amount = (params[:amount] || 199).to_i
  description = (params[:description] || "Sinatra Test")

  customer = Stripe::Customer.create(
    :email => params[:stripeEmail],
    :card  => params[:stripeToken]
  )

  charge = Stripe::Charge.create(
    :amount      => @amount,
    :description => description,
    :currency    => 'usd',
    :customer    => customer.id
  )

  erb :charge
end

__END__

@@ layout
<!DOCTYPE html>
<html>
  <head></head>
  <body>
    <%= yield %>
  </body>
</html>

@@ index
<form action="/charge" method="POST">
  <input type="hidden" name="amount" value="199"></input>
  <input type="hidden" name="description" value="Pixi Paint"></input>
  <script
    src="https://checkout.stripe.com/checkout.js" class="stripe-button"
    data-key="pk_znR9dUa0sPXSlVv2009vpWdtexnnq"
    data-image="/square-image.png"
    data-name="Demo Site"
    data-description="2 widgets ($20.00)"
    data-amount="2000">
  </script>
</form>

@@ charge
<h2>Thanks, you paid <strong>$<%= @amount / 100.0 %></strong>!</h2>
