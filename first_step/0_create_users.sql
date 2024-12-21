-- ������������ ���������� ���� ������
ALTER SESSION SET CONTAINER = XEPDB1;

-- ===========================================
-- �����
-- ===========================================

-- �������� ��������� ��������� �����������
SELECT TABLESPACE_NAME FROM DBA_TABLESPACES;

-- �������� ��������� ���������� ������������
CREATE TABLESPACE main_tablespace_LOK
DATAFILE 'main_tablespace_LOK.dbf'
SIZE 100M
AUTOEXTEND ON NEXT 5M
BLOCKSIZE 8192
EXTENT MANAGEMENT LOCAL;

-- �������� ��������� ���������� ������������
DROP TABLESPACE main_tablespace_LOK INCLUDING CONTENTS AND DATAFILES;

-- �������� ���������� ���������� ������������
CREATE TEMPORARY TABLESPACE temp_tablespace_LOK
TEMPFILE 'temp_tablespace_LOK.dbf'
SIZE 100M
AUTOEXTEND ON NEXT 5M
BLOCKSIZE 8192
EXTENT MANAGEMENT LOCAL;

-- �������� ���������� ���������� ������������
DROP TABLESPACE temp_tablespace_LOK INCLUDING CONTENTS AND DATAFILES;

-- �������� ���� ��� ��������������
CREATE ROLE LOK_ADMIN_ROLE;

-- �������� ������� ��� ������������-��������������
CREATE PROFILE LOK_ADMIN_PROFILE LIMIT
    PASSWORD_LIFE_TIME 180
    SESSIONS_PER_USER 10
    FAILED_LOGIN_ATTEMPTS 3
    PASSWORD_LOCK_TIME 3
    PASSWORD_REUSE_TIME 10
    PASSWORD_GRACE_TIME DEFAULT
    CONNECT_TIME 180
    IDLE_TIME 30;

-- ���������� ���������� ���� ��������������
GRANT
    CREATE SESSION,
    CREATE TABLE,
    CREATE VIEW,
    CREATE PROCEDURE,
    CREATE PROFILE,
    CREATE USER,
    DROP USER,
    CREATE ROLE,
    DROP PROFILE,
    CREATE TRIGGER,
    DROP ANY TRIGGER,
    CREATE ANY INDEX,
    CREATE TYPE,
    DROP ANY TYPE,
    EXECUTE ANY INDEXTYPE,
    CREATE ANY SEQUENCE
    TO LOK_ADMIN_ROLE WITH ADMIN OPTION;

-- �������� ������������-��������������
CREATE USER LOK_ADMIN IDENTIFIED BY password123;

-- ���������� ������� ��� ������������-��������������
ALTER USER LOK_ADMIN PROFILE LOK_ADMIN_PROFILE;

-- ��������� ��������� ���������� ������������ � �������������� ������
ALTER USER LOK_ADMIN DEFAULT TABLESPACE main_tablespace_LOK QUOTA UNLIMITED ON main_tablespace_LOK;

-- ��������� ���������� ���������� ������������
ALTER USER LOK_ADMIN TEMPORARY TABLESPACE temp_tablespace_LOK;

-- ���������� ���� �������������� ������������
GRANT LOK_ADMIN_ROLE TO LOK_ADMIN;

-- ���������� �������������� ����������
GRANT EXECUTE ON SYS.DBMS_CRYPTO TO LOK_ADMIN;
GRANT DBA TO LOK_ADMIN;

GRANT CREATE PROCEDURE TO LOK_ADMIN;
GRANT CREATE SESSION TO LOK_ADMIN;
GRANT ALTER SESSION TO LOK_ADMIN;

-- �������� ���������� ��� ������ � JSON
CREATE OR REPLACE DIRECTORY JSON_DIR AS '/opt/oracle/oradata';
GRANT READ, WRITE ON DIRECTORY JSON_DIR TO LOK_ADMIN;

-- ===========================================
-- ����
-- ===========================================

-- �������� ���� � ������������� ������������
CREATE ROLE LOK_USER_ROLE;

-- �������� ������� ��� ������������
CREATE PROFILE LOK_USER_PROFILE LIMIT
    PASSWORD_LIFE_TIME 180
    SESSIONS_PER_USER 20
    FAILED_LOGIN_ATTEMPTS 5
    PASSWORD_LOCK_TIME 3
    PASSWORD_REUSE_TIME 10
    CONNECT_TIME 180
    IDLE_TIME 60;

-- �������� ������������ � �������� ������������
CREATE USER LOK_USER IDENTIFIED BY simple123;

-- ���������� ������� ��� ������������
ALTER USER LOK_USER PROFILE LOK_USER_PROFILE;

-- ���������� ���������� ������������
GRANT CREATE SESSION TO LOK_USER;
GRANT LOK_USER_ROLE TO LOK_USER;

-- ���������� ������� � ���������� � ��������
GRANT EXECUTE ON LOK_ADMIN.get_all_roles TO LOK_USER_ROLE;
GRANT EXECUTE ON LOK_ADMIN.get_all_artists TO LOK_USER_ROLE;
GRANT EXECUTE ON LOK_ADMIN.get_all_songs TO LOK_USER_ROLE;
GRANT EXECUTE ON LOK_ADMIN.get_songs_sorted_by_date TO LOK_USER;
REVOKE EXECUTE ON LOK_ADMIN.add_playlist FROM LOK_USER;
REVOKE EXECUTE ON LOK_ADMIN.delete_playlist FROM LOK_USER;
REVOKE EXECUTE ON LOK_ADMIN.update_playlist FROM LOK_USER;
GRANT EXECUTE ON LOK_ADMIN.get_all_playlists TO LOK_USER_ROLE;
GRANT EXECUTE ON LOK_ADMIN.get_all_genres TO LOK_USER_ROLE;
GRANT EXECUTE ON LOK_ADMIN.get_all_playlists_user TO LOK_USER;
GRANT EXECUTE ON LOK_ADMIN.add_playlist_user TO LOK_USER;
GRANT EXECUTE ON LOK_ADMIN.delete_playlist_user TO LOK_USER;
GRANT EXECUTE ON LOK_ADMIN.update_playlist_user TO LOK_USER;

-- �������������� ���� �� �������
GRANT SELECT ON LOK_ADMIN.roles TO LOK_USER;
GRANT SELECT ON LOK_ADMIN.artists TO LOK_USER_ROLE;
GRANT SELECT ON LOK_ADMIN.songs TO LOK_USER_ROLE;
GRANT SELECT ON LOK_ADMIN.playlists TO LOK_USER_ROLE;
GRANT SELECT ON LOK_ADMIN.genres TO LOK_USER_ROLE;
GRANT SELECT ON LOK_ADMIN.songs TO LOK_USER;
GRANT SELECT ON LOK_ADMIN.artists TO LOK_USER;
GRANT SELECT ON LOK_ADMIN.genres TO LOK_USER;
GRANT SELECT ON LOK_ADMIN.playlists TO LOK_USER;

-- ���������� ���� �� �������������� ���������
GRANT EXECUTE ON LOK_ADMIN.add_song_to_playlist_user TO LOK_USER;
GRANT EXECUTE ON LOK_ADMIN.remove_song_from_playlist_user TO LOK_USER;
GRANT EXECUTE ON LOK_ADMIN.get_songs_from_playlist_user TO LOK_USER;