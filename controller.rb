def database()
    db = SQLite3::Database.new("db/db_login.db")
    db.results_as_hash = true
    db
end

def logged_in(params)
    db = database()
    if session[:username] != nil
        redirect('/produkter')
    end
end

def not_logged_in(params)
    db = database()
    if session[:username] == nil
        redirect('/login')
    end
end

def login(params)
    db = database()

    result = db.execute("SELECT Password, Id FROM users WHERE Username = '#{params["Username"]}'")
    
    if BCrypt::Password.new(result[0]["Password"]) == params["Password"]
        session[:username] = params["Username"]
        session[:user_id] = result[0]["Id"]
        redirect('/profil')
    else
        redirect('/failed')
    end
end

def register(params)
    db = database()
    new_password = params["Password"] 
    hashed_password = BCrypt::Password.create(new_password)

    db.execute("INSERT INTO users (Username, Password) VALUES (?, ?)", params["Username"], hashed_password)
    redirect('/login')
end

def edit_profile(params)
    db = database()

    if session[:username] == nil
        redirect('/')
    else
        slim(:edit_profile)
    end

    db = SQLite3::Database.new("db/db_login.db")
    db.execute(%Q(UPDATE users SET Username = '#{params['Rubrik']}' WHERE Id = #{session[:user_id]}))

    session.destroy
end

def moncler(params)
    db = database()
    prod_name1 = db.execute('SELECT Produkt_Namn,Pris FROM produkter WHERE Kategori = "Moncler"')
    slim(:moncler, locals:{product1: prod_name1})
end

def produkter(params)
    db = database()

    prod_name1 = db.execute('SELECT Kategori FROM produkter WHERE Id = "1"')
    prod_name2 = db.execute('SELECT Kategori FROM produkter WHERE Id = "2"')
    prod_name3= db.execute('SELECT Kategori FROM produkter WHERE Id = "3"')
    
    slim(:produkter, locals:{product1: prod_name1, product2: prod_name2, product3: prod_name3})
end

def köp(params) 
    db = database()

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
