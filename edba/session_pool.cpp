#include <edba/session_pool.hpp>
#include <boost/bind/bind.hpp>

namespace edba {

struct session_pool::connection_proxy : backend::connection_iface
{
    connection_proxy(session_pool& pool, const backend::connection_ptr& conn)
      : pool_(pool)
      , conn_(conn)
      , exec_time_on_init_(conn->total_execution_time())
    {
    }

    ~connection_proxy()
    {
        mutex::scoped_lock g(pool_.pool_guard_);
        pool_.total_sec_ += conn_->total_execution_time() - exec_time_on_init_;
        pool_.pool_.push_back(conn_);
        pool_.pool_max_cv_.notify_one();
    }

    virtual backend::statement_ptr prepare_statement(const string_ref& q)
    {
        return conn_->prepare_statement(q);
    }

    virtual backend::statement_ptr create_statement(const string_ref& q)
    {
        return conn_->create_statement(q);
    }

    virtual void exec_batch(const string_ref& q)
    {
        return conn_->exec_batch(q);
    }

    virtual void set_specific(const boost::any& data)
    {
        return conn_->set_specific(data);
    }

    virtual boost::any& get_specific()
    {
        return conn_->get_specific();
    }

    virtual void begin()
    {
        return conn_->begin();
    }

    virtual void commit()
    {
        return conn_->commit();
    }

    virtual void rollback()
    {
        return conn_->rollback();
    }

    virtual std::string escape(const string_ref& str)
    {
        return conn_->escape(str);
    }

    virtual const std::string& backend()
    {
        return conn_->backend();
    }

    virtual const std::string& engine()
    {
        return conn_->engine();
    }

    virtual void version(int& major, int& minor)
    {
        return conn_->version(major, minor);
    }

    virtual const std::string& description()
    {
        return conn_->description();
    }

    virtual double total_execution_time() const
    {
        return conn_->total_execution_time();
    }

    virtual const conn_info& connection_info() const
    {
        return conn_->connection_info();
    }

private:
    session_pool& pool_;
    backend::connection_ptr conn_;
    double exec_time_on_init_;
};

session_pool::session_pool(const char* conn_string, int max_pool_size, session_monitor* sm)
    : session_pool(conn_info(conn_string), max_pool_size, sm)
{
}

session_pool::session_pool(const conn_info& ci, int max_pool_size, session_monitor* sm)
    : conn_info_(ci)
    , conn_left_unopened_(max_pool_size)
    , sm_(sm)
    , total_sec_(0.0)
{
    pool_.reserve(max_pool_size);
}

void session_pool::invoke_on_connect(const conn_init_callback& callback)
{
    mutex::scoped_lock g(pool_guard_);
    conn_init_callback_ = callback;
}

session session_pool::open()
{
    mutex::scoped_lock g(pool_guard_);

    if (!pool_.empty())  // take connection from pool
    {
        session sess(create_proxy(pool_.back()));
        pool_.pop_back();
        return sess;
    }
    else if (pool_.empty() && conn_left_unopened_) // we can create new connection
    {
        backend::connection_ptr conn = driver_manager::create_conn(conn_info_, sm_);

        if (conn_init_callback_)
            // Don`t use proxy wrapper over connection because in case of exception in conn_init_callback_
            // proxy wrapper will try to lock non-recursive pool mutex, and we will get deadlock.
            conn_init_callback_(session(conn));

        // Now we can construct session using proxy connection
        session sess(create_proxy(conn));
        --conn_left_unopened_;

        return sess;
    }
    else // we must wait until someone will free connection for us
    {
        pool_max_cv_.wait(g, !boost::bind(&pool_type::empty, &pool_));
        assert(!pool_.empty() && "pool_ is not empty");

        session sess(create_proxy(pool_.back()));
        pool_.pop_back();
        return sess;
    }
}

bool session_pool::try_open(session& sess)
{
    mutex::scoped_lock g(pool_guard_);

    if (!pool_.empty())  // take connection from pool
    {
        sess = session(create_proxy(pool_.back()));
        pool_.pop_back();
    }
    else if (pool_.empty() && conn_left_unopened_) // we can create new connection
    {
        backend::connection_ptr conn = driver_manager::create_conn(conn_info_, sm_);
        if (conn_init_callback_)
            conn_init_callback_(session(conn));

        session tmp(create_proxy(conn));
        --conn_left_unopened_;

        sess = tmp;
    }
    else // we must wait until someone will free connection for us
        return false;

    return true;
}

double session_pool::total_execution_time()
{
    mutex::scoped_lock g(pool_guard_);
    return total_sec_;
}

backend::connection_ptr session_pool::create_proxy(const backend::connection_ptr& conn)
{
    return backend::connection_ptr(new connection_proxy(*this, conn));
}

}
