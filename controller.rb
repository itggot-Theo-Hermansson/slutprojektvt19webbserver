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

def admin(params)
    db = database()

    user_type = db.execute('SELECT User_type FROM users WHERE Id = ?', session[:user_id]).first
    
    if user_type['User_type'] == "Admin" 
        slim(:admin)
    else
        redirect('/produkter')
    end
end

def admin_tickets(params)
    db = database()
    session[:tickets] = db.execute('SELECT Username, Ticket FROM support_tickets')

    slim(:admin_help)
end

def remove_ticket(params)
    db = database()
    db.execute('DELETE FROM support_tickets WHERE Id = ?', session[:user_id])
    redirect('/admin/help')
end

def moncler(params)
    db = database()
    prod_name1 = db.execute('SELECT * FROM produkter WHERE Kategori = "Moncler"')
    slim(:moncler, locals:{product1: prod_name1})
end

def givenchy(params)
    db = database()
    prod_name1 = db.execute('SELECT * FROM produkter WHERE Kategori = "Givenchy"')
    slim(:givenchy, locals:{product1: prod_name1})
end

def produkter(params)
    db = database()

    prod_name1 = db.execute('SELECT Kategori FROM produkter WHERE Id = "1"')
    prod_name2 = db.execute('SELECT Kategori FROM produkter WHERE Id = "2"')
    prod_name3= db.execute('SELECT Kategori FROM produkter WHERE Id = "3"')
    
    slim(:produkter, locals:{product1: prod_name1, product2: prod_name2, product3: prod_name3})
end

def beställt(params)
    db = database()
    orders = db.execute('SELECT * FROM ordrar')

    slim(:beställt)
end

def stoneisland(params)
    db = database()
    prod_name1 = db.execute('SELECT * FROM produkter WHERE Kategori = "Stone-Island"')
    slim(:stoneisland, locals:{product1: prod_name1})
end

def buy(params)
    db = database() 
    amount = db.execute('SELECT Amount FROM produkter WHERE Id = ?', params['buy']).first
    antal_kvar = amount[0] - 1
    db.execute('UPDATE produkter SET Amount = ? WHERE Id = ?', antal_kvar, params['buy'])
    db.execute('INSERT INTO ordrar (Id) VALUES (?)', params['buy'])
    redirect back
end

def kundsupport(params)
    db = database()
    db.execute("INSERT INTO support_tickets (Id, Username, Ticket) VALUES (?, ?, ?)", session[:user_id], session[:username], params["Help"])

    redirect('/help')
end

