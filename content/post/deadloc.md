+++
author = "Jet He"
date = "2015-06-26T15:45:07+08:00"
description = "记一次wordpress中mysql的死锁分析"
keywords = ["MYSQL", "wordpress"]
tags = ["MYSQL"]
title = "deadlock of mysql"
topics = ["MYSQL"]
type = "post"

+++

没有想到在看似简单的场景里面也能遇到mysql的deadlock。

```
[Thu Jun 25 05:18:40.589897 2015] [:error] [pid 737] [client 172.17.42.1:41290] WordPress database error Deadlock found when trying to get lock; try restarting transaction for query UPDATE `wp_usermeta` SET `meta_value` = 'a:2:{s:64:\\"1161a6271c528045db428cc8698bbc8e3e26ad4fb9d7436e32cbbe01a00079d0\\";i:1436419120;s:64:\\"bf2e3582e17c7dfa1e6b02c700f537b8095f2b31ef58e4b448939eb9406e11f7\\";i:1435382320;}' WHERE `user_id` = 188 AND `meta_key` = 'session_tokens' made by require('wp-blog-header.php'), require_once('wp-includes/template-loader.php'), do_action('template_redirect'), call_user_func_array, anw_template_redirect, ANW_Base_Controller->process, call_user_func, ANW_AccountOnePage_Controller->authenticate, wp_signon, wp_set_auth_cookie, WP_Session_Tokens->create, WP_Session_Tokens->update, WP_User_Meta_Session_Tokens->update_session, WP_User_Meta_Session_Tokens->update_sessions, update_user_meta, update_metadata
```

这是wordpress本身的缺陷导致的，死锁的场景也是不复杂。即session_tokens的更新机制所致。
Session_tokens的更新是随着用户的login和 logout 更新的。Login时会增加session_tokens, 在不同的 浏览器 login会增加新的 tokens，在 logout时会删除这个 tokens。
这个死锁用户有两个 session，场景可能就是不同的浏览器同时做 login或者 logout，或者一个 login另一个 logout。看这个环境上有大量的用户存在，并且每个用户至多有两个 session，也只有跑性能脚本会有这个问题。现实情况比较难复现。

```
                /**
                * Update a user's sessions in the usermeta table.
                *
                * @since 4.0.0
                * @access protected
                *
                * @param array $sessions Sessions.
                */
                protected function update_sessions( $sessions ) {
                                if ( ! has_filter( 'attach_session_information' ) ) {
                                                $sessions = wp_list_pluck( $sessions, 'expiration' );
                                }

                                if ( $sessions ) {
                                                update_user_meta( $this->user_id, 'session_tokens', $sessions );
                                } else {
                                                delete_user_meta( $this->user_id, 'session_tokens' );
                                }
                }
```

看到这里应该要在仔细深入了解下mysql的加锁机制，当然这个会比较复杂，也不能一蹴而就。整体上重新熟悉下。
事务的隔离级别有四种，分别是READ UNCOMMITTED、READ COMMITTED、REPEATABLE READ、SERIALIZEABLE。mysql默认的是可重复读。

```
MariaDB [(none)]> show global variables like '%isolation%';
+---------------+-----------------+
| Variable_name | Value           |
+---------------+-----------------+
| tx_isolation  | REPEATABLE-READ |
+---------------+-----------------+
1 row in set (0.00 sec)
```

INNODB支持所有的事务隔离级别，但是MVCC只在REPEATABLE READ 和READ COMMITTED两个隔离级别下工作。
回到开始的问题。session_tokens 是真对用户在不同的终端上登录时进行更新的，value是个array，如上代码所示。如果同一个用户在两个终端上，可以是不同的浏览器即可，就会有不同的session_tokens，在登录登出的时候就会update改用户的数据，即同一行数据就可能产生死锁。这里必须是同时有两个事务。
现实中同一个用户在两个终端同时操作的可能性不大，但是也很难说。这也说明了wordpress的代码不够健壮吧。当然这里的死锁也并不可怕，INNODB会将持有最少行级排它锁的事务进行回滚。锁机制的了解还是要多多实践，网上也有较好的[文章参考](http://hedengcheng.com/?p=771)。
