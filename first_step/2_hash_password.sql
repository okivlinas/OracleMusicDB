CREATE OR REPLACE FUNCTION hash_password(f_password IN VARCHAR2)
    RETURN RAW
AS
BEGIN
    IF f_password IS NULL
    THEN
        RETURN NULL;
    ELSE
        -- ����������� ������ � �������������� SHA-256
        RETURN dbms_crypto.hash(utl_raw.cast_to_raw(f_password), dbms_crypto.hash_sh256);
    END IF;
END;

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION compare_passwords(
    user_id_p IN users.user_id%TYPE,
    password IN VARCHAR2
) RETURN NUMBER
IS
    hash RAW(32);
    user_password RAW(32);
BEGIN
    -- �������� ������ ������������ �� ����
    BEGIN
        SELECT user_password INTO user_password FROM users WHERE user_id = user_id_p;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- ���� ������������ �� ������, ���������� ������
            RETURN 0;
    END;

    -- �������� ��������� ������
    hash := hash_password(COALESCE(TRIM(password), ''));

    -- ���������� ���� �������
    IF hash = user_password THEN
        RETURN 1; -- ������ ���������
    ELSE
        RETURN 0; -- ������ �� ���������
    END IF;
END;
-----------------------------