def validate_register(params)
    if params["Username"].nil? || params["Password"].nil?
        return false
    else
        return true 
    end
end 

def validate_edit_profile(params)
    if params["Rubrik"].nil?
        return false
    else 
        return true
    end
end 


def validate_login(params)
    if params["Username"].nil? || params["Username"].length > 10 || params["Username"].length < 2 
        return false
    else 
        return true
    end
end 

def database()
    db = SQLite3::Database.new("db/db_login.db")
    db.results_as_hash = true
    db
end

def login(params)
    if validate_login(params)
        db = database()

        result = db.execute("SELECT Password, Id FROM users WHERE Username = '#{params["Username"]}'")
    
        if BCrypt::Password.new(result[0]["Password"]) == params["Password"]
            session[:username] = params["Username"]
            session[:user_id] = result[0]["Id"]
            redirect('/produkter')
        else
            redirect('/failed')
        end
    end
end

def register(params)
    if validate_register(params)
        db = database()
        new_password = params["Password"] 
        hashed_password = BCrypt::Password.create(new_password)

        db.execute("INSERT INTO users (Username, Password) VALUES (?, ?)", params["Username"], hashed_password)
    end
end

def edit_profile(params)
    if validate_edit_profile(params)
        db = database()

        db.execute(%Q(UPDATE users SET Username = '#{params['Rubrik']}' WHERE Id = #{session[:user_id]}))

        session.destroy
    end
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

def log_out(params)
    session.destroy
end

def admin_tickets(params)
    db = database()
    session[:tickets] = db.execute('SELECT Id, Username, Ticket FROM support_tickets')

    slim(:admin_help)
end

def remove_ticket(params)
    db = database()
    db.execute('DELETE FROM support_tickets WHERE Id = ?', params['solve'])
end

def moncler(params)
    db = database()
    original_price = db.execute('SELECT Pris FROM produkter WHERE Id = 3').first
    user_type = db.execute('SELECT User_type FROM users WHERE Id = ?', session[:user_id]).first 
    prod_name1 = db.execute('SELECT * FROM produkter WHERE Kategori = "Moncler"')
    if user_type['User_type'] == "Business"
        pris = original_price[0] * 0.8
    else
        pris = original_price[0]
    end

    slim(:moncler, locals:{product1: prod_name1, price: pris})
end

def givenchy(params)
    db = database()
    original_price = db.execute('SELECT Pris FROM produkter WHERE Id = 2').first
    user_type = db.execute('SELECT User_type FROM users WHERE Id = ?', session[:user_id]).first
    prod_name1 = db.execute('SELECT * FROM produkter WHERE Kategori = "Givenchy"')
    if user_type['User_type'] == "Business"
        pris = original_price[0] * 0.8
    else
        pris = original_price[0]
    end
    slim(:givenchy, locals:{product1: prod_name1, price: pris})
end

def produkter(params)
    db = database()

    prod_name1 = db.execute('SELECT Kategori FROM produkter WHERE Id = "1"')
    prod_name2 = db.execute('SELECT Kategori FROM produkter WHERE Id = "2"')
    prod_name3= db.execute('SELECT Kategori FROM produkter WHERE Id = "3"')
    
    slim(:produkter, locals:{product1: prod_name1, product2: prod_name2, product3: prod_name3})
end

def bought(params)
    db = database()
    ordrar = db.execute('SELECT * FROM ordrar')

    slim(:beställt, locals:{orders: ordrar})
end

def stoneisland(params)
    db = database()
    original_price = db.execute('SELECT Pris FROM produkter WHERE Id = 1').first
    user_type = db.execute('SELECT User_type FROM users WHERE Id = ?', session[:user_id]).first 
    prod_name1 = db.execute('SELECT * FROM produkter WHERE Kategori = "Stone-Island"')
    if user_type['User_type'] == "Business"
        pris = original_price[0] * 0.8
    else
        pris = original_price[0]
    end
    slim(:stoneisland, locals:{product1: prod_name1, price: pris})
end

def buy(params)
    db = database()
    amount = db.execute('SELECT Amount FROM produkter WHERE Id = ?', params['buy']).first
    session[:product] = db.execute('SELECT Produkt_Namn FROM produkter WHERE Id = ?', params['buy']).first
    antal_kvar = amount[0] - 1
    db.execute('UPDATE produkter SET Amount = ? WHERE Id = ?', antal_kvar, params['buy'])
    db.execute('INSERT INTO ordrar (Id) VALUES (?)', params['buy'])
end

def kundsupport(params)
    db = database()
    db.execute("INSERT INTO support_tickets (Id, Username, Ticket) VALUES (?, ?, ?)", session[:user_id], session[:username], params["Help"])

end

