require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'
require_relative 'model'

enable :sessions

configure do
    set :unsecured_paths, ['/', '/login', '/register']
end

before do
    unless settings.unsecured_paths.include?(request.path)
        if session[:user_id].nil?
            redirect('/')
        end
    end
end

get('/') do
    if session[:username] != nil
        redirect('/produkter')
    end
    slim(:home)
end

get('/login') do
    if session[:username] != nil
        redirect('/produkter')
    end
    slim(:login)
end

get('/admin') do
    if session[:username] == nil
        redirect('/login')
    end
    admin(params)
end

get('/admin/help') do
    if session[:username] == nil
        redirect('/login')
    end
    admin_tickets(params)
end

post('/admin/help') do
    remove_ticket(params)
    redirect('/admin/help')
end

get('/admin/beställt') do
    if session[:username] == nil
        redirect('/login')
    end
    bought(params)
end

get('/purchase_complete') do
    if session[:username] == nil
        redirect('/login')
    end
    slim(:purchase_complete)
end

post('/purchase_complete') do
    params(buy)
    produkter(params)
end

post('/login') do
    login(params)
end

get('/register') do
    if session[:username] != nil
        redirect('/produkter')
    end
    slim(:register)
end

post('/register') do
    register(params)
    redirect('/login')
end

get('/failed') do
    slim(:failed)
end

get('/profil') do
    if session[:username] == nil
        redirect('/login')
    end
    slim(:profil)
end

post('/profil') do
    log_out(params)
    redirect('/')
end

get('/edit_profile/:id') do
    slim(:edit_profile)
end

post('/edit_profile') do
    if session[:username] == nil
        redirect('/')
    else
        slim(:edit_profile)
    end
    edit_profile(params)
end

get('/produkter/moncler') do
    moncler(params)
end

post('/produkter/moncler') do
    buy(params)
    redirect('/purchase_complete')
end

get('/produkter') do
    produkter(params)
end

post('/produkter') do
    buy(params)
    redirect('/purchase_complete')
end

get('/produkter/Stone-Island') do
    stoneisland(params)
end

post('/produkter/Stone-Island') do
    buy(params)
    redirect('/purchase_complete')
end

get('/produkter/Givenchy') do
    givenchy(params)
end

post('/produkter/Givenchy') do
    buy(params)
    redirect('/purchase_complete')
end

get('/help') do
    if session[:username] == nil
        redirect('/login')
    end
    slim(:kundsupport)
end

post('/help') do
    kundsupport(params)
    redirect('/help')
end