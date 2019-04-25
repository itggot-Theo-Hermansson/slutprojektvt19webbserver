require 'sinatra'
require 'slim'
require 'sqlite3'
require 'byebug'
require 'bcrypt'
require_relative 'controller'

enable :sessions

get('/') do
    logged_in(params)
    slim(:home)
end

get('/login') do
    logged_in(params)
    slim(:login)
end

get('/admin') do
    not_logged_in(params)
    admin(params)
end

get('/admin/help') do
    admin_tickets(params)
end

post('/admin/help') do
    remove_ticket(params)
end

get('/admin/beställt') do
    beställt(params)
end

post('/login') do
    login(params)
end

get('/register') do
    logged_in(params)
    slim(:register)
end

post('/register') do
    register(params)
end

get('/failed') do
    slim(:failed)
end

get('/profil') do
    not_logged_in(params)
    slim(:profil)
end

get('/edit_profile/:id') do
    slim(:edit_profile)
end

post('/edit_profile') do
    edit_profile(params)
end

get('/produkter/moncler') do
    moncler(params)
end

post('/produkter/moncler') do
    buy(params)
end

get('/produkter') do
    produkter(params)
end

post('/produkter') do
    buy(params)
end

get('/produkter/Stone-Island') do
    stoneisland(params)
end

post('/produkter/Stone-Island') do
    buy(params)
end

get('/produkter/Givenchy') do
    givenchy(params)
end

post('/produkter/Givenchy') do
    buy(params)
end

get('/help') do
    not_logged_in(params)
    slim(:kundsupport)
end

post('/help') do
    kundsupport(params)
end