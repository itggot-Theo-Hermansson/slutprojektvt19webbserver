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
    db = SQLite3::Database.new("db/db_login.db")
    db.results_as_hash = true
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

get('/beställt') do
    db = SQLite3::Database.new("db/db_login.db")
    db.results_as_hash = true

    beställt = db.execute('SELECT * FROM ordrar')

    slim(:beställt, locals:{history: beställt})
end

get('/produkter') do
    produkter(params)
end

post('/produkter') do
    köp(params)
end