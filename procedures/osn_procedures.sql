-- ===========================================
-- ��������� ��� ������ � ������
-- ===========================================
CREATE OR REPLACE PROCEDURE add_role(p_role_name IN roles.role_name%TYPE)
AS
    v_count INTEGER;
BEGIN
    -- ���������, ���������� �� ��� ����� ����
    SELECT COUNT(*) INTO v_count
    FROM roles
    WHERE role_name = p_role_name;

    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('������: ���� � ����� ������ ��� ����������.');
    ELSE
        -- ��������� ����, ���� ��� �� ����������
        INSERT INTO roles (role_name)
        VALUES (p_role_name);
        DBMS_OUTPUT.PUT_LINE('���� "' || p_role_name || '" ������� ���������.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('����������� ������: ' || SQLERRM);
END add_role;
/

CREATE OR REPLACE PROCEDURE delete_role(p_role_id IN roles.role_id%TYPE)
AS
BEGIN
    DELETE FROM roles
    WHERE role_id = p_role_id;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������: ���� � ID ' || p_role_id || ' �� �������.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('���� � ID ' || p_role_id || ' ������� �������.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('����������� ������: ' || SQLERRM);
END delete_role;
/

CREATE OR REPLACE PROCEDURE update_role(
    p_role_id IN roles.role_id%TYPE,
    p_new_role_name IN roles.role_name%TYPE
)
AS
    v_count INTEGER;
BEGIN
    -- ��������, ���������� �� ���� � ����� ID
    SELECT COUNT(*) INTO v_count
    FROM roles
    WHERE role_id = p_role_id;

    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('������: ���� � ID ' || p_role_id || ' �� �������.');
    ELSE
        -- ���������� ����
        UPDATE roles
        SET role_name = p_new_role_name
        WHERE role_id = p_role_id;

        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('������: ���� � ID ' || p_role_id || ' �� ���������.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('���� � ID ' || p_role_id || ' ������� ��������� �� "' || p_new_role_name || '".');
        END IF;
    END IF;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('������: ���� � ����� ������ ��� ����������.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('����������� ������: ' || SQLERRM);
END update_role;
/

CREATE OR REPLACE PROCEDURE get_all_roles
AS
    CURSOR role_cursor IS
        SELECT role_id, role_name FROM roles;
    v_role_id roles.role_id%TYPE;
    v_role_name roles.role_name%TYPE;
BEGIN
    OPEN role_cursor;
    LOOP
        FETCH role_cursor INTO v_role_id, v_role_name;
        EXIT WHEN role_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID ����: ' || v_role_id || ', �������� ����: ' || v_role_name);
    END LOOP;
    CLOSE role_cursor;
END get_all_roles;
/
-- ===========================================
-- ��������� ��� ���������� �������������
-- ===========================================
CREATE OR REPLACE PROCEDURE add_artist(
    p_artist_name IN VARCHAR2,
    p_artist_description IN VARCHAR2  -- ��� �������� �� ���������
) AS
    v_exists NUMBER;
BEGIN
    -- �������� �� ������������� �����������
    SELECT COUNT(*)
    INTO v_exists
    FROM artists
    WHERE LOWER(artist_name) = LOWER(p_artist_name);

    IF v_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, '����������� � ����� ������ ��� ����������.');
    END IF;

    -- ���������� �����������
    INSERT INTO artists (artist_name, artist_description)
    VALUES (p_artist_name, p_artist_description);

    DBMS_OUTPUT.PUT_LINE('����������� "' || p_artist_name || '" ������� ��������.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('������ ��� ���������� �����������: ' || SQLERRM);
END add_artist;
/

CREATE OR REPLACE PROCEDURE delete_artist(
    p_artist_id IN INTEGER
) AS
    v_exists NUMBER; -- ���������� ��� �������� ������������� ������
BEGIN
    -- ���������, ���������� �� ����������� � ����� ID
    SELECT COUNT(*)
    INTO v_exists
    FROM artists
    WHERE artist_id = p_artist_id;

    IF v_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, '����������� � ����� ID �� ������.');
    END IF;

    -- ������� �����������
    DELETE FROM artists 
    WHERE artist_id = p_artist_id;

    DBMS_OUTPUT.PUT_LINE('����������� � ID ' || p_artist_id || ' ������� �����.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('������ ��� �������� �����������: ' || SQLERRM);
END delete_artist;
/

CREATE OR REPLACE PROCEDURE update_artist(
    p_artist_id IN INTEGER,
    p_artist_name IN VARCHAR2,
    p_artist_description IN VARCHAR2 DEFAULT NULL
) AS
    v_exists_id NUMBER; -- �������� ������� ����������� � ��������� ID
    v_exists_name NUMBER; -- �������� ������� ����������� � ��������� ������
BEGIN
    -- ���������, ���������� �� ����������� � ����� ID
    SELECT COUNT(*)
    INTO v_exists_id
    FROM artists
    WHERE artist_id = p_artist_id;

    IF v_exists_id = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, '����������� � ����� ID �� ������.');
    END IF;

    -- ���������, ���������� �� ��� ������ ����������� � ����� ������
    SELECT COUNT(*)
    INTO v_exists_name
    FROM artists
    WHERE LOWER(artist_name) = LOWER(p_artist_name)
      AND artist_id != p_artist_id;

    IF v_exists_name > 0 THEN
        RAISE_APPLICATION_ERROR(-20004, '����������� � ����� ������ ��� ����������.');
    END IF;

    -- ��������� ���������� �� �����������
    UPDATE artists
    SET artist_name = p_artist_name,
        artist_description = p_artist_description
    WHERE artist_id = p_artist_id;

    DBMS_OUTPUT.PUT_LINE('����������� � ID ' || p_artist_id || ' ������� �������.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('������ ��� ���������� �����������: ' || SQLERRM);
END update_artist;
/

CREATE OR REPLACE PROCEDURE get_all_artists
AS
    CURSOR artist_cursor IS
        SELECT artist_id, artist_name, artist_description FROM artists;
    v_artist_id artists.artist_id%TYPE;
    v_artist_name artists.artist_name%TYPE;
    v_artist_description artists.artist_description%TYPE;
BEGIN
    OPEN artist_cursor;
    LOOP
        FETCH artist_cursor INTO v_artist_id, v_artist_name, v_artist_description;
        EXIT WHEN artist_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID �����������: ' || v_artist_id || ', ���: ' || v_artist_name || ', ��������: ' || NVL(v_artist_description, '��� ��������'));
    END LOOP;
    CLOSE artist_cursor;
END get_all_artists;
/
-- ===========================================
-- ��������� ��� ����������� ������������
-- ===========================================
CREATE OR REPLACE PROCEDURE add_song(
    p_song_title IN VARCHAR2,
    p_genre_id IN INTEGER,
    p_artist_id IN INTEGER,
    p_song_path IN VARCHAR2
) AS
    v_genre_count INTEGER;
    v_artist_count INTEGER;
    v_duplicate_count INTEGER;
    v_path_exists INTEGER;
BEGIN
    -- ��������� ������ ����
    IF p_song_path IS NULL OR TRIM(p_song_path) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20004, '���� � ����� �� ����� ���� ������.');
    END IF;

    -- ��������� ������������� �����
    SELECT COUNT(*)
    INTO v_genre_count
    FROM genres
    WHERE genre_id = p_genre_id;

    IF v_genre_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, '��������� ���� �� ����������.');
    END IF;

    -- ��������� ������������� �����������
    SELECT COUNT(*)
    INTO v_artist_count
    FROM artists
    WHERE artist_id = p_artist_id;

    IF v_artist_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, '��������� ����������� �� ����������.');
    END IF;

    -- ��������� �� ������������ ���������� � ���������� ����
    SELECT COUNT(*)
    INTO v_path_exists
    FROM songs
    WHERE LOWER(song_path) = LOWER(p_song_path);

    IF v_path_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, '���������� � ����� ���� ��� ����������.');
    END IF;

    -- ��������� �� ������������ ���������� � ����� ���������, ������ � ������������
    SELECT COUNT(*)
    INTO v_duplicate_count
    FROM songs
    WHERE LOWER(song_title) = LOWER(p_song_title)
      AND genre_id = p_genre_id
      AND artist_id = p_artist_id;

    IF v_duplicate_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20005, '���������� � ����� ���������, ������ � ������������ ��� ����������.');
    END IF;

    -- ��������� ����� ����������
    INSERT INTO songs (song_title, genre_id, artist_id, song_path, added_date)
    VALUES (p_song_title, p_genre_id, p_artist_id, p_song_path, SYSDATE);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('���������� "' || p_song_title || '" ������� ���������.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ��� ���������� ����������: ' || SQLERRM);
END add_song;
/

CREATE OR REPLACE PROCEDURE delete_song(
    p_song_id IN INTEGER
) AS
    v_song_count INTEGER;
BEGIN
    -- ���������, ���������� �� ���������� � ����� ID
    SELECT COUNT(*)
    INTO v_song_count
    FROM songs
    WHERE song_id = p_song_id;

    IF v_song_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, '���������� � ��������� ID �� �������.');
    END IF;

    -- ������� ����������
    DELETE FROM songs WHERE song_id = p_song_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('���������� � ID ' || p_song_id || ' ������� �������.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ��� �������� ����������: ' || SQLERRM);
END delete_song;
/

CREATE OR REPLACE PROCEDURE update_song(
    p_song_id IN INTEGER,
    p_song_title IN VARCHAR2,
    p_genre_id IN INTEGER,
    p_artist_id IN INTEGER,
    p_song_path IN VARCHAR2,
    p_added_date IN DATE  -- ����� �������� ��� ����
) AS
    v_song_count INTEGER;
    v_genre_count INTEGER;
    v_artist_count INTEGER;
    v_duplicate_count INTEGER;
BEGIN
    -- ���������, ���������� �� ���������� � ����� ID
    SELECT COUNT(*)
    INTO v_song_count
    FROM songs
    WHERE song_id = p_song_id;

    IF v_song_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, '���������� � ��������� ID �� �������.');
    END IF;

    -- �������� �� ������ ����
    IF p_song_path IS NULL OR TRIM(p_song_path) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20010, '���� � ����� �� ����� ���� ������.');
    END IF;

    -- ���������, ��� �������� ���������� �� ������
    IF p_song_title IS NULL OR TRIM(p_song_title) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20006, '�������� ���������� �� ����� ���� ������.');
    END IF;

    -- ��������� ������������� �����
    SELECT COUNT(*)
    INTO v_genre_count
    FROM genres
    WHERE genre_id = p_genre_id;

    IF v_genre_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20007, '��������� ���� �� ����������.');
    END IF;

    -- ��������� ������������� �����������
    SELECT COUNT(*)
    INTO v_artist_count
    FROM artists
    WHERE artist_id = p_artist_id;

    IF v_artist_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20008, '��������� ����������� �� ����������.');
    END IF;

    -- ��������� �� ������������
    SELECT COUNT(*)
    INTO v_duplicate_count
    FROM songs
    WHERE LOWER(song_title) = LOWER(p_song_title)
      AND genre_id = p_genre_id
      AND artist_id = p_artist_id
      AND song_id != p_song_id;

    IF v_duplicate_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20009, '������ ���������� � ����� ���������, ������ � ������������ ��� ����������.');
    END IF;

    -- ��������� ����������
    UPDATE songs
    SET song_title = p_song_title,
        genre_id = p_genre_id,
        artist_id = p_artist_id,
        song_path = p_song_path,
        added_date = p_added_date  -- ���������� ���������� ����
    WHERE song_id = p_song_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('���������� � ID ' || p_song_id || ' ������� ���������.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ��� ���������� ����������: ' || SQLERRM);
END update_song;
/

CREATE OR REPLACE PROCEDURE get_all_songs AS
    CURSOR song_cursor IS
        SELECT song_id, song_title, genre_id, artist_id, song_path FROM songs;
    v_song_id songs.song_id%TYPE;
    v_song_title songs.song_title%TYPE;
    v_genre_id songs.genre_id%TYPE;
    v_artist_id songs.artist_id%TYPE;
    v_song_path songs.song_path%TYPE;
BEGIN
    OPEN song_cursor;
    LOOP
        FETCH song_cursor INTO v_song_id, v_song_title, v_genre_id, v_artist_id, v_song_path;
        EXIT WHEN song_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID ����������: ' || v_song_id || ', ��������: ' || v_song_title || ', ���� ID: ' || v_genre_id || ', ����������� ID: ' || v_artist_id || ', ���� � �����: ' || v_song_path);
    END LOOP;
    CLOSE song_cursor;
END get_all_songs;
/

CREATE OR REPLACE PROCEDURE get_songs_sorted_by_date AS
    CURSOR song_cursor IS
        SELECT song_id, song_title, artist_id, genre_id, song_path, added_date
        FROM songs
        ORDER BY added_date DESC;  -- ���������� �� ���� ���������� (����� ����� �������)

    song_record songs%ROWTYPE;  -- ���������� ��� �������� ������ ������ �� �������
BEGIN
    -- �������� �������
    OPEN song_cursor;

    -- ����� ����������
    DBMS_OUTPUT.PUT_LINE('Song ID | Song Title | Artist ID | Genre ID | Song Path | Added Date');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------');

    -- ���� ��� ������ ���� �����
    LOOP
        FETCH song_cursor INTO song_record;
        EXIT WHEN song_cursor%NOTFOUND;

        -- ����� ������ ��� ������ �����
        DBMS_OUTPUT.PUT_LINE(song_record.song_id || ' | ' || song_record.song_title || ' | ' || 
                             song_record.artist_id || ' | ' || song_record.genre_id || ' | ' ||
                             song_record.song_path || ' | ' || TO_CHAR(song_record.added_date, 'YYYY-MM-DD'));
    END LOOP;

    -- �������� �������
    CLOSE song_cursor;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('������ ��� ���������: ' || SQLERRM);
        IF song_cursor%ISOPEN THEN
            CLOSE song_cursor;
        END IF;
END get_songs_sorted_by_date;
/
-- ===========================================
-- ��������� ��� ����������� �����������
-- ===========================================
CREATE OR REPLACE PROCEDURE add_playlist(
    p_playlist_name IN VARCHAR2,
    p_user_id IN INTEGER  -- ����� �������� ��� �������� ������������
) AS
    v_count INTEGER;
BEGIN
    -- �������� �� ������ ��� ���������
    IF p_playlist_name IS NULL OR TRIM(p_playlist_name) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, '��� ��������� �� ����� ���� ������.');
    END IF;

    -- �������� �� ������������� ������������ � ��������� user_id
    SELECT COUNT(*)
    INTO v_count
    FROM users
    WHERE user_id = p_user_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, '������������ � ����� ID �� ����������.');
    END IF;

    -- �������� �� ������������ ���������
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE LOWER(playlist_name) = LOWER(p_playlist_name);

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, '�������� � ����� ������ ��� ����������.');
    END IF;

    -- ������� ������ ��������� � ��������� user_id
    INSERT INTO playlists (playlist_name, user_id)
    VALUES (p_playlist_name, p_user_id);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('�������� "' || p_playlist_name || '" ������� �������� ������������� � ID ' || p_user_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ��� ���������� ���������: ' || SQLERRM);
END add_playlist;
/

CREATE OR REPLACE PROCEDURE delete_playlist(
    p_playlist_id IN INTEGER
) AS
    v_count INTEGER;
BEGIN
    -- ��������, ���������� �� �������� � ����� ID
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE playlist_id = p_playlist_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, '�������� � ����� ID �� ������.');
    END IF;

    -- �������� ���������
    DELETE FROM playlists WHERE playlist_id = p_playlist_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('�������� � ID ' || p_playlist_id || ' ������� ������.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ��� �������� ���������: ' || SQLERRM);
END delete_playlist;
/

CREATE OR REPLACE PROCEDURE update_playlist(
    p_playlist_id IN INTEGER,
    p_new_playlist_name IN VARCHAR2,
    p_user_id IN INTEGER  -- ����� �������� ��� �������� ������������
) AS
    v_count INTEGER;
BEGIN
    -- �������� �� ������ ��� ���������
    IF p_new_playlist_name IS NULL OR TRIM(p_new_playlist_name) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20004, '��� ��������� �� ����� ���� ������.');
    END IF;

    -- �������� �� ������������� ������������ � ��������� user_id
    SELECT COUNT(*)
    INTO v_count
    FROM users
    WHERE user_id = p_user_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, '������������ � ����� ID �� ����������.');
    END IF;

    -- �������� �� ������������� ��������� � ����� ID � �������������� ������������
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE playlist_id = p_playlist_id
    AND user_id = p_user_id;  -- ��������� �������� �� �������������� ������������

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20006, '�������� � ����� ID �� ������ ��� �� �� ����������� ���������� ������������.');
    END IF;

    -- �������� �� ������������ ������ �����
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE LOWER(playlist_name) = LOWER(p_new_playlist_name)
      AND playlist_id != p_playlist_id;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20007, '�������� � ����� ������ ��� ����������.');
    END IF;

    -- ���������� ����� ���������
    UPDATE playlists
    SET playlist_name = p_new_playlist_name
    WHERE playlist_id = p_playlist_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('�������� � ID ' || p_playlist_id || ' ������� ��������.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ��� ���������� ���������: ' || SQLERRM);
END update_playlist;
/

CREATE OR REPLACE PROCEDURE get_all_playlists AS
    CURSOR playlist_cursor IS
        SELECT p.playlist_id, p.playlist_name, u.user_name
        FROM playlists p
        JOIN users u ON p.user_id = u.user_id;  -- ���������� � �������� users
    v_playlist_id playlists.playlist_id%TYPE;
    v_playlist_name playlists.playlist_name%TYPE;
    v_user_name users.user_name%TYPE;  -- ���������� ��� ����� ������������
BEGIN
    OPEN playlist_cursor;
    LOOP
        FETCH playlist_cursor INTO v_playlist_id, v_playlist_name, v_user_name;
        EXIT WHEN playlist_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID ���������: ' || v_playlist_id || ', ��������: ' || v_playlist_name || ', ������������: ' || v_user_name);
    END LOOP;
    CLOSE playlist_cursor;
END get_all_playlists;
/

CREATE OR REPLACE PROCEDURE add_playlist_user(
    p_playlist_name IN VARCHAR2,
    p_user_id IN INTEGER  -- ����� �������� ��� �������� ������������
) AS
    v_count INTEGER;
BEGIN
    -- �������� �� ������ ��� ���������
    IF p_playlist_name IS NULL OR TRIM(p_playlist_name) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, '��� ��������� �� ����� ���� ������.');
    END IF;

    -- �������� �� ������������� ������������ � ��������� user_id
    SELECT COUNT(*)
    INTO v_count
    FROM users
    WHERE user_id = p_user_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, '������������ � ����� ID �� ����������.');
    END IF;

    -- �������� �� ������������ ���������
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE LOWER(playlist_name) = LOWER(p_playlist_name)
      AND user_id = p_user_id;  -- �������� �� �������������� ������������

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, '�������� � ����� ������ ��� ����������.');
    END IF;

    -- ������� ������ ��������� � ��������� user_id
    INSERT INTO playlists (playlist_name, user_id)
    VALUES (p_playlist_name, p_user_id);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('�������� "' || p_playlist_name || '" ������� �������� ������������� � ID ' || p_user_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ��� ���������� ���������: ' || SQLERRM);
END add_playlist_user;
/

CREATE OR REPLACE PROCEDURE delete_playlist_user(
    p_playlist_id IN INTEGER,
    p_user_id IN INTEGER  -- ����� �������� ��� �������� ������������
) AS
    v_count INTEGER;
BEGIN
    -- ��������, ���������� �� �������� � ����� ID � ����������� �� �� ������������
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE playlist_id = p_playlist_id
    AND user_id = p_user_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, '�������� � ����� ID �� ������ ��� �� �� ����������� ���������� ������������.');
    END IF;

    -- �������� ���������
    DELETE FROM playlists WHERE playlist_id = p_playlist_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('�������� � ID ' || p_playlist_id || ' ������� ������.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ��� �������� ���������: ' || SQLERRM);
END delete_playlist_user;
/

CREATE OR REPLACE PROCEDURE update_playlist_user(
    p_playlist_id IN INTEGER,
    p_new_playlist_name IN VARCHAR2,
    p_user_id IN INTEGER  -- ����� �������� ��� �������� ������������
) AS
    v_count INTEGER;
BEGIN
    -- �������� �� ������ ��� ���������
    IF p_new_playlist_name IS NULL OR TRIM(p_new_playlist_name) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20004, '��� ��������� �� ����� ���� ������.');
    END IF;

    -- �������� �� ������������� ������������ � ��������� user_id
    SELECT COUNT(*)
    INTO v_count
    FROM users
    WHERE user_id = p_user_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, '������������ � ����� ID �� ����������.');
    END IF;

    -- �������� �� ������������� ��������� � ����� ID � �������������� ������������
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE playlist_id = p_playlist_id
    AND user_id = p_user_id;  -- ��������� �������� �� �������������� ������������

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20006, '�������� � ����� ID �� ������ ��� �� �� ����������� ���������� ������������.');
    END IF;

    -- �������� �� ������������ ������ �����
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE LOWER(playlist_name) = LOWER(p_new_playlist_name)
      AND playlist_id != p_playlist_id
      AND user_id = p_user_id;  -- �������� �� ������������ ��� ���� �� ������������

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20007, '�������� � ����� ������ ��� ����������.');
    END IF;

    -- ���������� ����� ���������
    UPDATE playlists
    SET playlist_name = p_new_playlist_name
    WHERE playlist_id = p_playlist_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('�������� � ID ' || p_playlist_id || ' ������� ��������.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ��� ���������� ���������: ' || SQLERRM);
END update_playlist_user;
/

CREATE OR REPLACE PROCEDURE get_all_playlists_user(
    p_user_id IN INTEGER  -- ����� �������� ��� �������� ������������
) AS
    CURSOR playlist_cursor IS
        SELECT p.playlist_id, p.playlist_name, u.user_name
        FROM playlists p
        JOIN users u ON p.user_id = u.user_id
        WHERE p.user_id = p_user_id;  -- ���������� �� user_id
    v_playlist_id playlists.playlist_id%TYPE;
    v_playlist_name playlists.playlist_name%TYPE;
    v_user_name users.user_name%TYPE;  -- ���������� ��� ����� ������������
BEGIN
    OPEN playlist_cursor;
    LOOP
        FETCH playlist_cursor INTO v_playlist_id, v_playlist_name, v_user_name;
        EXIT WHEN playlist_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID ���������: ' || v_playlist_id || ', ��������: ' || v_playlist_name || ', ������������: ' || v_user_name);
    END LOOP;
    CLOSE playlist_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('������ ��� ��������� ����������: ' || SQLERRM);
END get_all_playlists_user;
/

BEGIN
    LOK_ADMIN.add_playlist_user('��� ����� ���hhh�������', 4);
END;
BEGIN
    LOK_ADMIN.delete_playlist_user(1, 4);  -- 1 - ID ��������� ��� ��������, 4 - user_id
END;
BEGIN
    LOK_ADMIN.update_playlist_user(7, '����������� ��������', 4);  -- 1 - ID ���������, '����������� ��������' - ����� ���, 4 - user_id
END;
BEGIN
    LOK_ADMIN.get_all_playlists_user(4);  -- 4 - user_id, ��� ��������� ����� ��������
END;
EXEC add_playlist('��� ����� ����������', 3);
EXEC delete_playlist(3);
EXEC update_playlist(3, 'Updated Playlist', 2);
EXEC get_all_playlists;

-- ===========================================
-- ��������� ��� ���������� ��������������
-- ===========================================
CREATE OR REPLACE PROCEDURE add_user(
    p_user_name    IN VARCHAR2,
    p_user_email   IN VARCHAR2,
    p_user_password IN VARCHAR2,
    p_role_id      IN INTEGER
) AS
    v_count INTEGER;
    v_hashed_password RAW(32);  -- ��� ��� ������
BEGIN
    -- �������� �� ������ ��� ������������
    IF p_user_name IS NULL OR TRIM(p_user_name) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, '��� ������������ �� ����� ���� ������.');
    END IF;

    -- �������� �� ������ email
    IF p_user_email IS NULL OR TRIM(p_user_email) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'Email ������������ �� ����� ���� ������.');
    END IF;

    -- �������� �� ���������� email
    IF NOT REGEXP_LIKE(p_user_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
        RAISE_APPLICATION_ERROR(-20003, '������������ ������ email.');
    END IF;

    -- �������� �� ������ ������
    IF p_user_password IS NULL OR TRIM(p_user_password) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20004, '������ ������������ �� ����� ���� ������.');
    END IF;

    -- �������� �� ������������� ����
    SELECT COUNT(*)
    INTO v_count
    FROM roles  -- ����� ��������������, ��� ���� ������� roles, ��� �������� ���� �������������
    WHERE role_id = p_role_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, '���� � ����� ID �� ����������.');
    END IF;

    -- �������� �� ������������ ����� ������������
    SELECT COUNT(*)
    INTO v_count
    FROM users
    WHERE LOWER(user_name) = LOWER(p_user_name);

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20006, '������������ � ����� ������ ��� ����������.');
    END IF;

    -- �������� �� ������������ email
    SELECT COUNT(*)
    INTO v_count
    FROM users
    WHERE LOWER(user_email) = LOWER(p_user_email);

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20007, '������������ � ����� email ��� ����������.');
    END IF;

    -- �������� ������ ����� ����������� � ����
    v_hashed_password := hash_password(p_user_password);  -- ����� �������� ���� ������� �����������

    -- ������� ������ ������������
    INSERT INTO users (user_name, user_email, user_password, user_role)
    VALUES (p_user_name, p_user_email, v_hashed_password, p_role_id);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('������������ "' || p_user_name || '" ������� ��������.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ��� ���������� ������������: ' || SQLERRM);
END add_user;
/

CREATE OR REPLACE PROCEDURE delete_user(
    p_user_id IN INTEGER
) AS
    v_count INTEGER;
BEGIN
    -- �������� �� ������������� ������������ � ����� ID
    SELECT COUNT(*)
    INTO v_count
    FROM users
    WHERE user_id = p_user_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20006, '������������ � ����� ID �� ������.');
    END IF;

    -- �������� ������������
    DELETE FROM users WHERE user_id = p_user_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('������������ � ID ' || p_user_id || ' ������� ������.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ��� �������� ������������: ' || SQLERRM);
END delete_user;
/

CREATE OR REPLACE PROCEDURE update_user(
    p_user_id      IN INTEGER,
    p_user_name    IN VARCHAR2,
    p_user_email   IN VARCHAR2,
    p_user_password IN VARCHAR2,
    p_role_id      IN INTEGER
) AS
    v_count INTEGER;
    v_hashed_password RAW(32);  -- ��� ��� ������
BEGIN
    -- �������� �� ������ ��� ������������
    IF p_user_name IS NULL OR TRIM(p_user_name) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20007, '��� ������������ �� ����� ���� ������.');
    END IF;

    -- �������� �� ������ email
    IF p_user_email IS NULL OR TRIM(p_user_email) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20008, 'Email ������������ �� ����� ���� ������.');
    END IF;

    -- �������� �� ���������� email
    IF NOT REGEXP_LIKE(p_user_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
        RAISE_APPLICATION_ERROR(-20009, '������������ ������ email.');
    END IF;

    -- �������� �� ������ ������
    IF p_user_password IS NULL OR TRIM(p_user_password) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20010, '������ ������������ �� ����� ���� ������.');
    END IF;

    -- �������� �� ������������� ������������ � ����� ID
    SELECT COUNT(*)
    INTO v_count
    FROM users
    WHERE user_id = p_user_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20011, '������������ � ����� ID �� ������.');
    END IF;

    -- �������� �� ������������� ����
    SELECT COUNT(*)
    INTO v_count
    FROM roles  -- ����� ��������������, ��� ���� ������� roles, ��� �������� ���� �������������
    WHERE role_id = p_role_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20012, '���� � ����� ID �� ����������.');
    END IF;

    -- �������� �� ������������ ������ ����� ������������
    SELECT COUNT(*)
    INTO v_count
    FROM users
    WHERE LOWER(user_name) = LOWER(p_user_name)
      AND user_id != p_user_id;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20013, '������������ � ����� ������ ��� ����������.');
    END IF;

    -- �������� �� ������������ ������ email
    SELECT COUNT(*)
    INTO v_count
    FROM users
    WHERE LOWER(user_email) = LOWER(p_user_email)
      AND user_id != p_user_id;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20014, '������������ � ����� email ��� ����������.');
    END IF;

    -- �������� ����� ������
    v_hashed_password := hash_password(p_user_password);  -- ����� �������� ���� ������� �����������

    -- ���������� ������ ������������
    UPDATE users
    SET user_name = p_user_name,
        user_email = p_user_email,
        user_password = v_hashed_password,
        user_role = p_role_id  -- ��������� ����
    WHERE user_id = p_user_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('������ ������������ � ID ' || p_user_id || ' ������� ���������.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ��� ���������� ������ ������������: ' || SQLERRM);
END update_user;
/

CREATE OR REPLACE PROCEDURE get_all_users AS
    CURSOR user_cursor IS
        SELECT user_id, user_name, user_email, user_password, user_role FROM users;
    v_user_id users.user_id%TYPE;
    v_user_name users.user_name%TYPE;
    v_user_email users.user_email%TYPE;
    v_user_password users.user_password%TYPE;
    v_user_role users.user_role%TYPE;
BEGIN
    OPEN user_cursor;
    LOOP
        FETCH user_cursor INTO v_user_id, v_user_name, v_user_email, v_user_password, v_user_role;
        EXIT WHEN user_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID ������������: ' || v_user_id || ', ���: ' || v_user_name || 
                             ', Email: ' || v_user_email || ', ������ (���): ' || v_user_password || 
                             ', ����: ' || v_user_role);
    END LOOP;
    CLOSE user_cursor;
END get_all_users;
/
-- ===========================================
-- ����� ��� ����������� �������
-- ===========================================
CREATE OR REPLACE PROCEDURE add_genre(
    p_genre_name IN VARCHAR2
) AS
    v_count INTEGER;
BEGIN
    -- �������� �� ������ ��� �����
    IF p_genre_name IS NULL OR TRIM(p_genre_name) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, '��� ����� �� ����� ���� ������.');
    END IF;

    -- �������� �� ������������ �����
    SELECT COUNT(*)
    INTO v_count
    FROM genres
    WHERE LOWER(genre_name) = LOWER(p_genre_name);

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, '���� � ����� ������ ��� ����������.');
    END IF;

    -- ������� ������ �����
    INSERT INTO genres (genre_name)
    VALUES (p_genre_name);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('���� "' || p_genre_name || '" ������� ��������.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ��� ���������� �����: ' || SQLERRM);
END add_genre;
/

CREATE OR REPLACE PROCEDURE delete_genre(
    p_genre_id IN INTEGER
) AS
    v_count INTEGER;
BEGIN
    -- ��������, ���������� �� ���� � ����� ID
    SELECT COUNT(*)
    INTO v_count
    FROM genres
    WHERE genre_id = p_genre_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, '���� � ����� ID �� ������.');
    END IF;

    -- �������� �����
    DELETE FROM genres WHERE genre_id = p_genre_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('���� � ID ' || p_genre_id || ' ������� ������.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ��� �������� �����: ' || SQLERRM);
END delete_genre;
/

CREATE OR REPLACE PROCEDURE update_genre(
    p_genre_id IN INTEGER,
    p_new_genre_name IN VARCHAR2
) AS
    v_count INTEGER;
BEGIN
    -- �������� �� ������ ��� �����
    IF p_new_genre_name IS NULL OR TRIM(p_new_genre_name) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20004, '��� ����� �� ����� ���� ������.');
    END IF;

    -- �������� �� ������������� ����� � ����� ID
    SELECT COUNT(*)
    INTO v_count
    FROM genres
    WHERE genre_id = p_genre_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, '���� � ����� ID �� ������.');
    END IF;

    -- �������� �� ������������ ������ �����
    SELECT COUNT(*)
    INTO v_count
    FROM genres
    WHERE LOWER(genre_name) = LOWER(p_new_genre_name)
      AND genre_id != p_genre_id;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20006, '���� � ����� ������ ��� ����������.');
    END IF;

    -- ���������� ����� �����
    UPDATE genres
    SET genre_name = p_new_genre_name
    WHERE genre_id = p_genre_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('���� � ID ' || p_genre_id || ' ������� ��������.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ��� ���������� �����: ' || SQLERRM);
END update_genre;
/

CREATE OR REPLACE PROCEDURE get_all_genres AS
    CURSOR genre_cursor IS
        SELECT genre_id, genre_name FROM genres;
    v_genre_id genres.genre_id%TYPE;
    v_genre_name genres.genre_name%TYPE;
BEGIN
    OPEN genre_cursor;
    LOOP
        FETCH genre_cursor INTO v_genre_id, v_genre_name;
        EXIT WHEN genre_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID �����: ' || v_genre_id || ', ��������: ' || v_genre_name);
    END LOOP;
    CLOSE genre_cursor;
END get_all_genres;
/

-------

CREATE OR REPLACE PROCEDURE add_song_to_playlist_user(
    p_playlist_id IN INTEGER,
    p_song_id IN INTEGER,
    p_user_id IN INTEGER  -- ����� �������� ��� �������� ������������
) AS
    v_count INTEGER;
BEGIN
    -- �������� �� ������������� ��������� � ����� ID � �������������� ������������
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE playlist_id = p_playlist_id
    AND user_id = p_user_id;  -- ��������� �������� �� �������������� ������������

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, '�������� � ����� ID �� ������ ��� �� �� ����������� ���������� ������������.');
    END IF;

    -- �������� �� ������������� ����� � ����� ID
    SELECT COUNT(*)
    INTO v_count
    FROM songs
    WHERE song_id = p_song_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, '����� � ����� ID �� ����������.');
    END IF;

    -- ���������� ����� � ��������
    INSERT INTO playlist_song (playlist_id, song_id)
    VALUES (p_playlist_id, p_song_id);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('����� � ID ' || p_song_id || ' ������� ��������� � �������� � ID ' || p_playlist_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ��� ���������� ����� � ��������: ' || SQLERRM);
END add_song_to_playlist_user;
/

CREATE OR REPLACE PROCEDURE remove_song_from_playlist_user(
    p_playlist_id IN INTEGER,
    p_song_id IN INTEGER,
    p_user_id IN INTEGER  -- ����� �������� ��� �������� ������������
) AS
    v_count INTEGER;
BEGIN
    -- �������� �� ������������� ��������� � ����� ID � �������������� ������������
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE playlist_id = p_playlist_id
    AND user_id = p_user_id;  -- ��������� �������� �� �������������� ������������

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, '�������� � ����� ID �� ������ ��� �� �� ����������� ���������� ������������.');
    END IF;

    -- �������� �� ������������� ����� � ��������� ���������
    SELECT COUNT(*)
    INTO v_count
    FROM playlist_song
    WHERE playlist_id = p_playlist_id
    AND song_id = p_song_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, '����� � ����� ID �� ������� � ���������.');
    END IF;

    -- �������� ����� �� ���������
    DELETE FROM playlist_song
    WHERE playlist_id = p_playlist_id
    AND song_id = p_song_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('����� � ID ' || p_song_id || ' ������� ������� �� ��������� � ID ' || p_playlist_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ��� �������� ����� �� ���������: ' || SQLERRM);
END remove_song_from_playlist_user;
/

CREATE OR REPLACE PROCEDURE get_songs_from_playlist_user(
    p_playlist_id IN INTEGER,
    p_user_id IN INTEGER  -- ����� �������� ��� �������� ������������
) AS
    CURSOR playlist_song_cursor IS
        SELECT ps.id, s.song_title, s.song_id
        FROM playlist_song ps
        JOIN songs s ON ps.song_id = s.song_id
        JOIN playlists p ON ps.playlist_id = p.playlist_id
        WHERE p.playlist_id = p_playlist_id
        AND p.user_id = p_user_id;  -- ��������� �������� �� �������������� ������������
    
    v_id playlist_song.id%TYPE;
    v_song_title songs.song_title%TYPE;
    v_song_id songs.song_id%TYPE;
    v_count INTEGER;  -- ��������� ���������� ��� �������� ���������� ����������
BEGIN
    -- �������� �� ������������� ��������� � ����� ID � �������������� ������������
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE playlist_id = p_playlist_id
    AND user_id = p_user_id;  -- ��������� �������� �� �������������� ������������

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, '�������� � ����� ID �� ������ ��� �� �� ����������� ���������� ������������.');
    END IF;

    OPEN playlist_song_cursor;
    LOOP
        FETCH playlist_song_cursor INTO v_id, v_song_title, v_song_id;
        EXIT WHEN playlist_song_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID �����: ' || v_song_id || ', ��������: ' || v_song_title);
    END LOOP;
    CLOSE playlist_song_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('������ ��� ��������� ����� � ���������: ' || SQLERRM);
END get_songs_from_playlist_user;
/

CREATE OR REPLACE PROCEDURE add_song_to_playlist(
    p_playlist_id IN INTEGER,
    p_song_id IN INTEGER
) AS
    v_count INTEGER;
BEGIN
    -- �������� �� ������������� ��������� � ����� ID
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE playlist_id = p_playlist_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, '�������� � ����� ID �� ������.');
    END IF;

    -- �������� �� ������������� ����� � ����� ID
    SELECT COUNT(*)
    INTO v_count
    FROM songs
    WHERE song_id = p_song_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, '����� � ����� ID �� �������.');
    END IF;

    -- ������� ����� � ��������
    INSERT INTO playlist_song (playlist_id, song_id)
    VALUES (p_playlist_id, p_song_id);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('����� � ID ' || p_song_id || ' ������� ��������� � �������� � ID ' || p_playlist_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ��� ���������� ����� � ��������: ' || SQLERRM);
END add_song_to_playlist;
/

CREATE OR REPLACE PROCEDURE remove_song_from_playlist(
    p_playlist_id IN INTEGER,
    p_song_id IN INTEGER
) AS
    v_count INTEGER;
BEGIN
    -- �������� �� ������������� ��������� � ����� ID
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE playlist_id = p_playlist_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, '�������� � ����� ID �� ������.');
    END IF;

    -- �������� �� ������������� ����� � ���������
    SELECT COUNT(*)
    INTO v_count
    FROM playlist_song
    WHERE playlist_id = p_playlist_id
    AND song_id = p_song_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, '����� � ����� ID �� ������� � ���������.');
    END IF;

    -- �������� ����� �� ���������
    DELETE FROM playlist_song
    WHERE playlist_id = p_playlist_id
    AND song_id = p_song_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('����� � ID ' || p_song_id || ' ������� ������� �� ��������� � ID ' || p_playlist_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('������ ��� �������� ����� �� ���������: ' || SQLERRM);
END remove_song_from_playlist;
/

CREATE OR REPLACE PROCEDURE get_songs_from_playlist(
    p_playlist_id IN INTEGER
) AS
    -- ���������� ����������
    v_count INTEGER;  -- ��������� ���������� ��� �������� ������������� ���������
    CURSOR playlist_song_cursor IS
        SELECT ps.id, s.song_title, s.song_id
        FROM playlist_song ps
        JOIN songs s ON ps.song_id = s.song_id
        WHERE ps.playlist_id = p_playlist_id;
    
    v_id playlist_song.id%TYPE;
    v_song_title songs.song_title%TYPE;
    v_song_id songs.song_id%TYPE;
BEGIN
    -- �������� �� ������������� ��������� � ����� ID
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE playlist_id = p_playlist_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, '�������� � ����� ID �� ������.');
    END IF;

    OPEN playlist_song_cursor;
    LOOP
        FETCH playlist_song_cursor INTO v_id, v_song_title, v_song_id;
        EXIT WHEN playlist_song_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID �����: ' || v_song_id || ', ��������: ' || v_song_title);
    END LOOP;
    CLOSE playlist_song_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('������ ��� ��������� ����� � ���������: ' || SQLERRM);
END get_songs_from_playlist;
/