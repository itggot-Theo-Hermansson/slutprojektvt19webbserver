require 'sinatra'
require 'slim'
require 'sqlite3'
require 'byebug'
require 'bcrypt'

enable :sessions

get('/') do
    if session[:username] != nil
        redirect('/logged_in')
    end 
    slim(:home)
end

get('/login') do
    if session[:user_id] != nil
        redirect('/logged_in')
    end
    slim(:login)
end

post('/login') do
    db = SQLite3::Database.new("db/db_login.db")
    db.results_as_hash = true

    result = db.execute("SELECT Password, Id FROM users WHERE Username = '#{params["Username"]}'")
    
    if BCrypt::Password.new(result[0]["Password"]) == params["Password"]
        session[:username] = params["Username"]
        session[:user_id] = result[0]["Id"]
        redirect('/profil')
    else
        redirect('/failed')
    end

end

get('/register') do
    if session[:user_id] != nil
        redirect('/logged_in')
    end
    slim(:register)
end

post('/register') do
    db = SQLite3::Database.new("db/db_login.db")   
    new_password = params["Password"] 
    hashed_password = BCrypt::Password.create(new_password)

    db.execute("INSERT INTO users (Username, Password) VALUES (?, ?)", params["Username"], hashed_password)
    redirect('/login')
end

get('/logged_in') do
    db = SQLite3::Database.new("db/db_login.db")
    if session[:username] == nil
        redirect('/')
    else
        slim(:logged_in)
    end
end

get('/failed') do
    slim(:failed)
end

get('/profil') do
    if session[:username] == nil
        redirect('/')
    else
        slim(:profil)
    end
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

    db = SQLite3::Database.new("db/db_login.db")
    db.execute(%Q(UPDATE users SET Username = '#{params['Rubrik']}' WHERE Id = #{session[:user_id]}))

    session.destroy
    redirect back 
end

get('/produkter/moncler') do
    db = SQLite3::Database.new("db/db_login.db")
    db.results_as_hash = true

    prod_name1 = db.execute('SELECT Produkt_Namn,Pris FROM produkter WHERE Kategori = "Moncler"')
    slim(:moncler, locals:{product1: prod_name1})
end

get('/beställt') do
    db = SQLite3::Database.new("db/db_login.db")
    db.results_as_hash = true

    beställt = db.execute('SELECT * FROM ordrar')

    slim(:beställt, locals:{history: beställt})
end

get('/produkter') do
    db = SQLite3::Database.new("db/db_login.db")
    db.results_as_hash = true

    prod_name1 = db.execute('SELECT Kategori FROM produkter WHERE Id = "1"')
    prod_name2 = db.execute('SELECT Kategori FROM produkter WHERE Id = "2"')
    prod_name3= db.execute('SELECT Kategori FROM produkter WHERE Id = "3"')
    
    slim(:produkter, locals:{product1: prod_name1, product2: prod_name2, product3: prod_name3})
end

post('/produkter') do
    db = SQLite3::Database.new("db/db_login.db")
    db.results_as_hash = true

    product = db.execute('SELECT * FROM produkter WHERE Id = "1"')
    amount = product[0]['mängd']
    price = product[0]['pris']
    boughtAmount = params['product1'].to_i
    total = 0

    if params['product1'] != nil
        amount = amount - (boughtAmount)
        db.execute('UPDATE produkter SET amount = ? WHERE Id = "1"',amount)
        total = price * boughtAmount
        db.execute('INSERT INTO ordrar (Id, mängd, pris, antal_kvar) VALUES ("1", ?, ?, ?)',boughtAmount,total,amount,session[:Id])
        redirect('/produkter')
    else
        redirect('/produkter')
    end
    
    redirect('/produkter')
end