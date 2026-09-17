CONNECT SYS/&1 AS SYSDBA;

-- 1. Install APEX
@"C:\19c_24.2\Oracle APEX 24.2\apex\apexins.sql" sysaux sysaux temp /i/

-- 2. Configure APEX ADMIN user (non-interactively)
-- apex_chpwd requires prompting, so we use PL/SQL directly:
BEGIN
  APEX_UTIL.set_security_group_id( 10 );
  APEX_UTIL.create_user(
      p_user_name       => 'ADMIN',
      p_email_address   => 'admin@example.com',
      p_web_password    => '&1',
      p_developer_privs => 'ADMIN' );
  APEX_UTIL.set_security_group_id( null );
  COMMIT;
END;
/

-- 3. Configure Network ACLs (Whitelisting) for outbound APEX requests (Web Services, Emails)
BEGIN
    DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
        host => '*',
        ace => xs$ace_type(privilege_list => xs$name_list('connect', 'resolve'),
                           principal_name => 'APEX_240200',
                           principal_type => xs_acl.ptype_db)
    );
END;
/

-- 4. Unlock APEX_PUBLIC_USER and set password
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY &1 ACCOUNT UNLOCK;

-- 5. Configure REST Users
@"C:\19c_24.2\Oracle APEX 24.2\apex\apex_rest_config_core.sql" @ &1 &1

EXIT;
