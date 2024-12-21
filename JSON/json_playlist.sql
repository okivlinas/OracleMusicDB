CREATE OR REPLACE PROCEDURE export_genres_to_json IS
    l_json_str VARCHAR2(4000); -- ������ ��� ������������ JSON
    l_file UTL_FILE.FILE_TYPE;
    l_directory CONSTANT VARCHAR2(100) := 'JSON_DIR'; -- ������� ��� �������� JSON
    is_first_record BOOLEAN := TRUE; -- ���� ��� ������ ������
BEGIN
    -- ��������� ���� ��� ������
    l_file := UTL_FILE.FOPEN(l_directory, 'genres.json', 'w', 32767);

    -- ���������� ����������� ������ ������� JSON
    UTL_FILE.PUT_LINE(l_file, '[');

    -- ���� �� ������� �� ������� ������
    FOR rec IN (SELECT genre_id, genre_name FROM genres) LOOP
        -- ���� �� ������ ������, ��������� ������� ����� ����� �������
        IF NOT is_first_record THEN
            UTL_FILE.PUT_LINE(l_file, ',');
        ELSE
            is_first_record := FALSE; -- ���������� ���� ����� ������ ������
        END IF;

        -- ��������� JSON-������ ��� ������� ������
        l_json_str := '{"genre_id":' || rec.genre_id || ',"genre_name":"' || rec.genre_name || '"}';

        -- ���������� ������ JSON � ����
        UTL_FILE.PUT_LINE(l_file, l_json_str);
    END LOOP;

    -- ��������� ������ JSON � ����
    UTL_FILE.PUT_LINE(l_file, ']');
    UTL_FILE.FCLOSE(l_file);

    DBMS_OUTPUT.PUT_LINE('������ ������� �������������� � ���� genres.json');
EXCEPTION
    WHEN OTHERS THEN
        IF UTL_FILE.IS_OPEN(l_file) THEN
            UTL_FILE.FCLOSE(l_file);
        END IF;
        RAISE;
END;
/


-- ������ ������ �� JSON � ������� genres
CREATE OR REPLACE PROCEDURE import_genres_from_json IS
    l_file UTL_FILE.FILE_TYPE;
    l_json_str VARCHAR2(4000);
    l_genre_id NUMBER;
    l_genre_name VARCHAR2(50);
    l_directory CONSTANT VARCHAR2(100) := 'JSON_DIR'; -- ��� ��������
BEGIN
    -- ��������� ���� ��� ������
    l_file := UTL_FILE.FOPEN(l_directory, 'genres.json', 'r');

    -- ������ ����������� ������ ������� JSON (�� ������������ �)
    UTL_FILE.GET_LINE(l_file, l_json_str); -- ���������� ������ � [

    -- ������ ��������� ������ �� ����������� ������
    LOOP
        BEGIN
            -- ������ ������ �� ����� (������ ������ JSON)
            UTL_FILE.GET_LINE(l_file, l_json_str);

            -- ��������� ����, ���� ������ ����������� ������ ]
            IF l_json_str = ']' THEN
                EXIT;
            END IF;

            -- ������ JSON ������ � ��������� ��������
            -- ������ JSON: {"genre_id":1, "genre_name":"Rock"}
            l_genre_id := TO_NUMBER(REGEXP_SUBSTR(l_json_str, '"genre_id":([0-9]+)', 1, 1, NULL, 1));
            l_genre_name := REGEXP_SUBSTR(l_json_str, '"genre_name":"([^"]+)"', 1, 1, NULL, 1);
            
            -- ��������� ������ � �������
            INSERT INTO genres (genre_id, genre_name)
            VALUES (l_genre_id, l_genre_name);

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                EXIT; -- �����������, ���� ��� ������
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('������ ��� ������� ������: ' || l_json_str);
        END;
    END LOOP;

    -- ��������� ����
    UTL_FILE.FCLOSE(l_file);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('������ ������� ������������� �� ����� genres.json');
EXCEPTION
    WHEN OTHERS THEN
        IF UTL_FILE.IS_OPEN(l_file) THEN
            UTL_FILE.FCLOSE(l_file);
        END IF;
        RAISE;
END;
/

BEGIN
    export_genres_to_json;
END;
/
BEGIN
    import_genres_from_json;
END;
/
