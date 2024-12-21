-- ===========================================
-- Процедуры для работы с ролями
-- ===========================================
CREATE OR REPLACE PROCEDURE add_role(p_role_name IN roles.role_name%TYPE)
AS
    v_count INTEGER;
BEGIN
    -- Проверяем, существует ли уже такая роль
    SELECT COUNT(*) INTO v_count
    FROM roles
    WHERE role_name = p_role_name;

    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: Роль с таким именем уже существует.');
    ELSE
        -- Вставляем роль, если она не существует
        INSERT INTO roles (role_name)
        VALUES (p_role_name);
        DBMS_OUTPUT.PUT_LINE('Роль "' || p_role_name || '" успешно добавлена.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Неизвестная ошибка: ' || SQLERRM);
END add_role;
/

CREATE OR REPLACE PROCEDURE delete_role(p_role_id IN roles.role_id%TYPE)
AS
BEGIN
    DELETE FROM roles
    WHERE role_id = p_role_id;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: Роль с ID ' || p_role_id || ' не найдена.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Роль с ID ' || p_role_id || ' успешно удалена.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Неизвестная ошибка: ' || SQLERRM);
END delete_role;
/

CREATE OR REPLACE PROCEDURE update_role(
    p_role_id IN roles.role_id%TYPE,
    p_new_role_name IN roles.role_name%TYPE
)
AS
    v_count INTEGER;
BEGIN
    -- Проверка, существует ли роль с таким ID
    SELECT COUNT(*) INTO v_count
    FROM roles
    WHERE role_id = p_role_id;

    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: Роль с ID ' || p_role_id || ' не найдена.');
    ELSE
        -- Обновление роли
        UPDATE roles
        SET role_name = p_new_role_name
        WHERE role_id = p_role_id;

        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: Роль с ID ' || p_role_id || ' не обновлена.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Роль с ID ' || p_role_id || ' успешно обновлена на "' || p_new_role_name || '".');
        END IF;
    END IF;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка: Роль с таким именем уже существует.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Неизвестная ошибка: ' || SQLERRM);
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
        DBMS_OUTPUT.PUT_LINE('ID роли: ' || v_role_id || ', Название роли: ' || v_role_name);
    END LOOP;
    CLOSE role_cursor;
END get_all_roles;
/
-- ===========================================
-- Процедура для управления исполнителями
-- ===========================================
CREATE OR REPLACE PROCEDURE add_artist(
    p_artist_name IN VARCHAR2,
    p_artist_description IN VARCHAR2  -- Без значения по умолчанию
) AS
    v_exists NUMBER;
BEGIN
    -- Проверка на существование исполнителя
    SELECT COUNT(*)
    INTO v_exists
    FROM artists
    WHERE LOWER(artist_name) = LOWER(p_artist_name);

    IF v_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Исполнитель с таким именем уже существует.');
    END IF;

    -- Добавление исполнителя
    INSERT INTO artists (artist_name, artist_description)
    VALUES (p_artist_name, p_artist_description);

    DBMS_OUTPUT.PUT_LINE('Исполнитель "' || p_artist_name || '" успешно добавлен.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка при добавлении исполнителя: ' || SQLERRM);
END add_artist;
/

CREATE OR REPLACE PROCEDURE delete_artist(
    p_artist_id IN INTEGER
) AS
    v_exists NUMBER; -- Переменная для проверки существования записи
BEGIN
    -- Проверяем, существует ли исполнитель с таким ID
    SELECT COUNT(*)
    INTO v_exists
    FROM artists
    WHERE artist_id = p_artist_id;

    IF v_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Исполнитель с таким ID не найден.');
    END IF;

    -- Удаляем исполнителя
    DELETE FROM artists 
    WHERE artist_id = p_artist_id;

    DBMS_OUTPUT.PUT_LINE('Исполнитель с ID ' || p_artist_id || ' успешно удалён.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка при удалении исполнителя: ' || SQLERRM);
END delete_artist;
/

CREATE OR REPLACE PROCEDURE update_artist(
    p_artist_id IN INTEGER,
    p_artist_name IN VARCHAR2,
    p_artist_description IN VARCHAR2 DEFAULT NULL
) AS
    v_exists_id NUMBER; -- Проверка наличия исполнителя с указанным ID
    v_exists_name NUMBER; -- Проверка наличия исполнителя с указанным именем
BEGIN
    -- Проверяем, существует ли исполнитель с таким ID
    SELECT COUNT(*)
    INTO v_exists_id
    FROM artists
    WHERE artist_id = p_artist_id;

    IF v_exists_id = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Исполнитель с таким ID не найден.');
    END IF;

    -- Проверяем, существует ли уже другой исполнитель с таким именем
    SELECT COUNT(*)
    INTO v_exists_name
    FROM artists
    WHERE LOWER(artist_name) = LOWER(p_artist_name)
      AND artist_id != p_artist_id;

    IF v_exists_name > 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Исполнитель с таким именем уже существует.');
    END IF;

    -- Обновляем информацию об исполнителе
    UPDATE artists
    SET artist_name = p_artist_name,
        artist_description = p_artist_description
    WHERE artist_id = p_artist_id;

    DBMS_OUTPUT.PUT_LINE('Исполнитель с ID ' || p_artist_id || ' успешно обновлён.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка при обновлении исполнителя: ' || SQLERRM);
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
        DBMS_OUTPUT.PUT_LINE('ID исполнителя: ' || v_artist_id || ', Имя: ' || v_artist_name || ', Описание: ' || NVL(v_artist_description, 'Нет описания'));
    END LOOP;
    CLOSE artist_cursor;
END get_all_artists;
/
-- ===========================================
-- Процедуры для управлением композициями
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
    -- Проверяем пустой путь
    IF p_song_path IS NULL OR TRIM(p_song_path) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20004, 'Путь к файлу не может быть пустым.');
    END IF;

    -- Проверяем существование жанра
    SELECT COUNT(*)
    INTO v_genre_count
    FROM genres
    WHERE genre_id = p_genre_id;

    IF v_genre_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Указанный жанр не существует.');
    END IF;

    -- Проверяем существование исполнителя
    SELECT COUNT(*)
    INTO v_artist_count
    FROM artists
    WHERE artist_id = p_artist_id;

    IF v_artist_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Указанный исполнитель не существует.');
    END IF;

    -- Проверяем на дублирование композиции с одинаковым путём
    SELECT COUNT(*)
    INTO v_path_exists
    FROM songs
    WHERE LOWER(song_path) = LOWER(p_song_path);

    IF v_path_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Композиция с таким путём уже существует.');
    END IF;

    -- Проверяем на дублирование композиции с таким названием, жанром и исполнителем
    SELECT COUNT(*)
    INTO v_duplicate_count
    FROM songs
    WHERE LOWER(song_title) = LOWER(p_song_title)
      AND genre_id = p_genre_id
      AND artist_id = p_artist_id;

    IF v_duplicate_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Композиция с таким названием, жанром и исполнителем уже существует.');
    END IF;

    -- Вставляем новую композицию
    INSERT INTO songs (song_title, genre_id, artist_id, song_path, added_date)
    VALUES (p_song_title, p_genre_id, p_artist_id, p_song_path, SYSDATE);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Композиция "' || p_song_title || '" успешно добавлена.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка при добавлении композиции: ' || SQLERRM);
END add_song;
/

CREATE OR REPLACE PROCEDURE delete_song(
    p_song_id IN INTEGER
) AS
    v_song_count INTEGER;
BEGIN
    -- Проверяем, существует ли композиция с таким ID
    SELECT COUNT(*)
    INTO v_song_count
    FROM songs
    WHERE song_id = p_song_id;

    IF v_song_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Композиция с указанным ID не найдена.');
    END IF;

    -- Удаляем композицию
    DELETE FROM songs WHERE song_id = p_song_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Композиция с ID ' || p_song_id || ' успешно удалена.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка при удалении композиции: ' || SQLERRM);
END delete_song;
/

CREATE OR REPLACE PROCEDURE update_song(
    p_song_id IN INTEGER,
    p_song_title IN VARCHAR2,
    p_genre_id IN INTEGER,
    p_artist_id IN INTEGER,
    p_song_path IN VARCHAR2,
    p_added_date IN DATE  -- Новый параметр для даты
) AS
    v_song_count INTEGER;
    v_genre_count INTEGER;
    v_artist_count INTEGER;
    v_duplicate_count INTEGER;
BEGIN
    -- Проверяем, существует ли композиция с таким ID
    SELECT COUNT(*)
    INTO v_song_count
    FROM songs
    WHERE song_id = p_song_id;

    IF v_song_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Композиция с указанным ID не найдена.');
    END IF;

    -- Проверка на пустой путь
    IF p_song_path IS NULL OR TRIM(p_song_path) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20010, 'Путь к файлу не может быть пустым.');
    END IF;

    -- Проверяем, что название композиции не пустое
    IF p_song_title IS NULL OR TRIM(p_song_title) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20006, 'Название композиции не может быть пустым.');
    END IF;

    -- Проверяем существование жанра
    SELECT COUNT(*)
    INTO v_genre_count
    FROM genres
    WHERE genre_id = p_genre_id;

    IF v_genre_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Указанный жанр не существует.');
    END IF;

    -- Проверяем существование исполнителя
    SELECT COUNT(*)
    INTO v_artist_count
    FROM artists
    WHERE artist_id = p_artist_id;

    IF v_artist_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20008, 'Указанный исполнитель не существует.');
    END IF;

    -- Проверяем на дублирование
    SELECT COUNT(*)
    INTO v_duplicate_count
    FROM songs
    WHERE LOWER(song_title) = LOWER(p_song_title)
      AND genre_id = p_genre_id
      AND artist_id = p_artist_id
      AND song_id != p_song_id;

    IF v_duplicate_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20009, 'Другая композиция с таким названием, жанром и исполнителем уже существует.');
    END IF;

    -- Обновляем композицию
    UPDATE songs
    SET song_title = p_song_title,
        genre_id = p_genre_id,
        artist_id = p_artist_id,
        song_path = p_song_path,
        added_date = p_added_date  -- Используем переданную дату
    WHERE song_id = p_song_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Композиция с ID ' || p_song_id || ' успешно обновлена.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка при обновлении композиции: ' || SQLERRM);
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
        DBMS_OUTPUT.PUT_LINE('ID композиции: ' || v_song_id || ', Название: ' || v_song_title || ', Жанр ID: ' || v_genre_id || ', Исполнитель ID: ' || v_artist_id || ', Путь к файлу: ' || v_song_path);
    END LOOP;
    CLOSE song_cursor;
END get_all_songs;
/

CREATE OR REPLACE PROCEDURE get_songs_sorted_by_date AS
    CURSOR song_cursor IS
        SELECT song_id, song_title, artist_id, genre_id, song_path, added_date
        FROM songs
        ORDER BY added_date DESC;  -- Сортировка по дате добавления (новые песни первыми)

    song_record songs%ROWTYPE;  -- Переменная для хранения строки данных из курсора
BEGIN
    -- Открытие курсора
    OPEN song_cursor;

    -- Вывод заголовков
    DBMS_OUTPUT.PUT_LINE('Song ID | Song Title | Artist ID | Genre ID | Song Path | Added Date');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------');

    -- Цикл для обхода всех песен
    LOOP
        FETCH song_cursor INTO song_record;
        EXIT WHEN song_cursor%NOTFOUND;

        -- Вывод данных для каждой песни
        DBMS_OUTPUT.PUT_LINE(song_record.song_id || ' | ' || song_record.song_title || ' | ' || 
                             song_record.artist_id || ' | ' || song_record.genre_id || ' | ' ||
                             song_record.song_path || ' | ' || TO_CHAR(song_record.added_date, 'YYYY-MM-DD'));
    END LOOP;

    -- Закрытие курсора
    CLOSE song_cursor;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка при обработке: ' || SQLERRM);
        IF song_cursor%ISOPEN THEN
            CLOSE song_cursor;
        END IF;
END get_songs_sorted_by_date;
/
-- ===========================================
-- Процедуры для управлением плейлистами
-- ===========================================
CREATE OR REPLACE PROCEDURE add_playlist(
    p_playlist_name IN VARCHAR2,
    p_user_id IN INTEGER  -- новый параметр для указания пользователя
) AS
    v_count INTEGER;
BEGIN
    -- Проверка на пустое имя плейлиста
    IF p_playlist_name IS NULL OR TRIM(p_playlist_name) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Имя плейлиста не может быть пустым.');
    END IF;

    -- Проверка на существование пользователя с указанным user_id
    SELECT COUNT(*)
    INTO v_count
    FROM users
    WHERE user_id = p_user_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Пользователь с таким ID не существует.');
    END IF;

    -- Проверка на уникальность плейлиста
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE LOWER(playlist_name) = LOWER(p_playlist_name);

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Плейлист с таким именем уже существует.');
    END IF;

    -- Вставка нового плейлиста с указанием user_id
    INSERT INTO playlists (playlist_name, user_id)
    VALUES (p_playlist_name, p_user_id);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Плейлист "' || p_playlist_name || '" успешно добавлен пользователем с ID ' || p_user_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка при добавлении плейлиста: ' || SQLERRM);
END add_playlist;
/

CREATE OR REPLACE PROCEDURE delete_playlist(
    p_playlist_id IN INTEGER
) AS
    v_count INTEGER;
BEGIN
    -- Проверка, существует ли плейлист с таким ID
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE playlist_id = p_playlist_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Плейлист с таким ID не найден.');
    END IF;

    -- Удаление плейлиста
    DELETE FROM playlists WHERE playlist_id = p_playlist_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Плейлист с ID ' || p_playlist_id || ' успешно удален.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка при удалении плейлиста: ' || SQLERRM);
END delete_playlist;
/

CREATE OR REPLACE PROCEDURE update_playlist(
    p_playlist_id IN INTEGER,
    p_new_playlist_name IN VARCHAR2,
    p_user_id IN INTEGER  -- новый параметр для указания пользователя
) AS
    v_count INTEGER;
BEGIN
    -- Проверка на пустое имя плейлиста
    IF p_new_playlist_name IS NULL OR TRIM(p_new_playlist_name) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20004, 'Имя плейлиста не может быть пустым.');
    END IF;

    -- Проверка на существование пользователя с указанным user_id
    SELECT COUNT(*)
    INTO v_count
    FROM users
    WHERE user_id = p_user_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Пользователь с таким ID не существует.');
    END IF;

    -- Проверка на существование плейлиста с таким ID и принадлежность пользователю
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE playlist_id = p_playlist_id
    AND user_id = p_user_id;  -- добавлена проверка на принадлежность пользователю

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Плейлист с таким ID не найден или он не принадлежит указанному пользователю.');
    END IF;

    -- Проверка на уникальность нового имени
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE LOWER(playlist_name) = LOWER(p_new_playlist_name)
      AND playlist_id != p_playlist_id;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Плейлист с таким именем уже существует.');
    END IF;

    -- Обновление имени плейлиста
    UPDATE playlists
    SET playlist_name = p_new_playlist_name
    WHERE playlist_id = p_playlist_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Плейлист с ID ' || p_playlist_id || ' успешно обновлен.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка при обновлении плейлиста: ' || SQLERRM);
END update_playlist;
/

CREATE OR REPLACE PROCEDURE get_all_playlists AS
    CURSOR playlist_cursor IS
        SELECT p.playlist_id, p.playlist_name, u.user_name
        FROM playlists p
        JOIN users u ON p.user_id = u.user_id;  -- Соединение с таблицей users
    v_playlist_id playlists.playlist_id%TYPE;
    v_playlist_name playlists.playlist_name%TYPE;
    v_user_name users.user_name%TYPE;  -- Переменная для имени пользователя
BEGIN
    OPEN playlist_cursor;
    LOOP
        FETCH playlist_cursor INTO v_playlist_id, v_playlist_name, v_user_name;
        EXIT WHEN playlist_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID плейлиста: ' || v_playlist_id || ', Название: ' || v_playlist_name || ', Пользователь: ' || v_user_name);
    END LOOP;
    CLOSE playlist_cursor;
END get_all_playlists;
/

CREATE OR REPLACE PROCEDURE add_playlist_user(
    p_playlist_name IN VARCHAR2,
    p_user_id IN INTEGER  -- новый параметр для указания пользователя
) AS
    v_count INTEGER;
BEGIN
    -- Проверка на пустое имя плейлиста
    IF p_playlist_name IS NULL OR TRIM(p_playlist_name) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Имя плейлиста не может быть пустым.');
    END IF;

    -- Проверка на существование пользователя с указанным user_id
    SELECT COUNT(*)
    INTO v_count
    FROM users
    WHERE user_id = p_user_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Пользователь с таким ID не существует.');
    END IF;

    -- Проверка на уникальность плейлиста
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE LOWER(playlist_name) = LOWER(p_playlist_name)
      AND user_id = p_user_id;  -- проверка на принадлежность пользователю

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Плейлист с таким именем уже существует.');
    END IF;

    -- Вставка нового плейлиста с указанием user_id
    INSERT INTO playlists (playlist_name, user_id)
    VALUES (p_playlist_name, p_user_id);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Плейлист "' || p_playlist_name || '" успешно добавлен пользователем с ID ' || p_user_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка при добавлении плейлиста: ' || SQLERRM);
END add_playlist_user;
/

CREATE OR REPLACE PROCEDURE delete_playlist_user(
    p_playlist_id IN INTEGER,
    p_user_id IN INTEGER  -- новый параметр для указания пользователя
) AS
    v_count INTEGER;
BEGIN
    -- Проверка, существует ли плейлист с таким ID и принадлежит ли он пользователю
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE playlist_id = p_playlist_id
    AND user_id = p_user_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Плейлист с таким ID не найден или он не принадлежит указанному пользователю.');
    END IF;

    -- Удаление плейлиста
    DELETE FROM playlists WHERE playlist_id = p_playlist_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Плейлист с ID ' || p_playlist_id || ' успешно удален.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка при удалении плейлиста: ' || SQLERRM);
END delete_playlist_user;
/

CREATE OR REPLACE PROCEDURE update_playlist_user(
    p_playlist_id IN INTEGER,
    p_new_playlist_name IN VARCHAR2,
    p_user_id IN INTEGER  -- новый параметр для указания пользователя
) AS
    v_count INTEGER;
BEGIN
    -- Проверка на пустое имя плейлиста
    IF p_new_playlist_name IS NULL OR TRIM(p_new_playlist_name) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20004, 'Имя плейлиста не может быть пустым.');
    END IF;

    -- Проверка на существование пользователя с указанным user_id
    SELECT COUNT(*)
    INTO v_count
    FROM users
    WHERE user_id = p_user_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Пользователь с таким ID не существует.');
    END IF;

    -- Проверка на существование плейлиста с таким ID и принадлежность пользователю
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE playlist_id = p_playlist_id
    AND user_id = p_user_id;  -- добавлена проверка на принадлежность пользователю

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Плейлист с таким ID не найден или он не принадлежит указанному пользователю.');
    END IF;

    -- Проверка на уникальность нового имени
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE LOWER(playlist_name) = LOWER(p_new_playlist_name)
      AND playlist_id != p_playlist_id
      AND user_id = p_user_id;  -- проверка на уникальность для того же пользователя

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Плейлист с таким именем уже существует.');
    END IF;

    -- Обновление имени плейлиста
    UPDATE playlists
    SET playlist_name = p_new_playlist_name
    WHERE playlist_id = p_playlist_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Плейлист с ID ' || p_playlist_id || ' успешно обновлен.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка при обновлении плейлиста: ' || SQLERRM);
END update_playlist_user;
/

CREATE OR REPLACE PROCEDURE get_all_playlists_user(
    p_user_id IN INTEGER  -- новый параметр для указания пользователя
) AS
    CURSOR playlist_cursor IS
        SELECT p.playlist_id, p.playlist_name, u.user_name
        FROM playlists p
        JOIN users u ON p.user_id = u.user_id
        WHERE p.user_id = p_user_id;  -- фильтрация по user_id
    v_playlist_id playlists.playlist_id%TYPE;
    v_playlist_name playlists.playlist_name%TYPE;
    v_user_name users.user_name%TYPE;  -- Переменная для имени пользователя
BEGIN
    OPEN playlist_cursor;
    LOOP
        FETCH playlist_cursor INTO v_playlist_id, v_playlist_name, v_user_name;
        EXIT WHEN playlist_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID плейлиста: ' || v_playlist_id || ', Название: ' || v_playlist_name || ', Пользователь: ' || v_user_name);
    END LOOP;
    CLOSE playlist_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка при получении плейлистов: ' || SQLERRM);
END get_all_playlists_user;
/

BEGIN
    LOK_ADMIN.add_playlist_user('Мой новый плеhhhйлистаа', 4);
END;
BEGIN
    LOK_ADMIN.delete_playlist_user(1, 4);  -- 1 - ID плейлиста для удаления, 4 - user_id
END;
BEGIN
    LOK_ADMIN.update_playlist_user(7, 'Обновленный плейлист', 4);  -- 1 - ID плейлиста, 'Обновленный плейлист' - новое имя, 4 - user_id
END;
BEGIN
    LOK_ADMIN.get_all_playlists_user(4);  -- 4 - user_id, чьи плейлисты нужно получить
END;
EXEC add_playlist('Мой новый плейлистаа', 3);
EXEC delete_playlist(3);
EXEC update_playlist(3, 'Updated Playlist', 2);
EXEC get_all_playlists;

-- ===========================================
-- Процедуры для управления пользователями
-- ===========================================
CREATE OR REPLACE PROCEDURE add_user(
    p_user_name    IN VARCHAR2,
    p_user_email   IN VARCHAR2,
    p_user_password IN VARCHAR2,
    p_role_id      IN INTEGER
) AS
    v_count INTEGER;
    v_hashed_password RAW(32);  -- Хеш для пароля
BEGIN
    -- Проверка на пустое имя пользователя
    IF p_user_name IS NULL OR TRIM(p_user_name) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Имя пользователя не может быть пустым.');
    END IF;

    -- Проверка на пустой email
    IF p_user_email IS NULL OR TRIM(p_user_email) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'Email пользователя не может быть пустым.');
    END IF;

    -- Проверка на валидность email
    IF NOT REGEXP_LIKE(p_user_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
        RAISE_APPLICATION_ERROR(-20003, 'Некорректный формат email.');
    END IF;

    -- Проверка на пустой пароль
    IF p_user_password IS NULL OR TRIM(p_user_password) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20004, 'Пароль пользователя не может быть пустым.');
    END IF;

    -- Проверка на существование роли
    SELECT COUNT(*)
    INTO v_count
    FROM roles  -- Здесь предполагается, что есть таблица roles, где хранятся роли пользователей
    WHERE role_id = p_role_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Роль с таким ID не существует.');
    END IF;

    -- Проверка на уникальность имени пользователя
    SELECT COUNT(*)
    INTO v_count
    FROM users
    WHERE LOWER(user_name) = LOWER(p_user_name);

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Пользователь с таким именем уже существует.');
    END IF;

    -- Проверка на уникальность email
    SELECT COUNT(*)
    INTO v_count
    FROM users
    WHERE LOWER(user_email) = LOWER(p_user_email);

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Пользователь с таким email уже существует.');
    END IF;

    -- Хешируем пароль перед добавлением в базу
    v_hashed_password := hash_password(p_user_password);  -- Здесь вызываем вашу функцию хеширования

    -- Вставка нового пользователя
    INSERT INTO users (user_name, user_email, user_password, user_role)
    VALUES (p_user_name, p_user_email, v_hashed_password, p_role_id);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Пользователь "' || p_user_name || '" успешно добавлен.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка при добавлении пользователя: ' || SQLERRM);
END add_user;
/

CREATE OR REPLACE PROCEDURE delete_user(
    p_user_id IN INTEGER
) AS
    v_count INTEGER;
BEGIN
    -- Проверка на существование пользователя с таким ID
    SELECT COUNT(*)
    INTO v_count
    FROM users
    WHERE user_id = p_user_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Пользователь с таким ID не найден.');
    END IF;

    -- Удаление пользователя
    DELETE FROM users WHERE user_id = p_user_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Пользователь с ID ' || p_user_id || ' успешно удален.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка при удалении пользователя: ' || SQLERRM);
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
    v_hashed_password RAW(32);  -- Хеш для пароля
BEGIN
    -- Проверка на пустое имя пользователя
    IF p_user_name IS NULL OR TRIM(p_user_name) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20007, 'Имя пользователя не может быть пустым.');
    END IF;

    -- Проверка на пустой email
    IF p_user_email IS NULL OR TRIM(p_user_email) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20008, 'Email пользователя не может быть пустым.');
    END IF;

    -- Проверка на валидность email
    IF NOT REGEXP_LIKE(p_user_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
        RAISE_APPLICATION_ERROR(-20009, 'Некорректный формат email.');
    END IF;

    -- Проверка на пустой пароль
    IF p_user_password IS NULL OR TRIM(p_user_password) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20010, 'Пароль пользователя не может быть пустым.');
    END IF;

    -- Проверка на существование пользователя с таким ID
    SELECT COUNT(*)
    INTO v_count
    FROM users
    WHERE user_id = p_user_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 'Пользователь с таким ID не найден.');
    END IF;

    -- Проверка на существование роли
    SELECT COUNT(*)
    INTO v_count
    FROM roles  -- Здесь предполагается, что есть таблица roles, где хранятся роли пользователей
    WHERE role_id = p_role_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20012, 'Роль с таким ID не существует.');
    END IF;

    -- Проверка на уникальность нового имени пользователя
    SELECT COUNT(*)
    INTO v_count
    FROM users
    WHERE LOWER(user_name) = LOWER(p_user_name)
      AND user_id != p_user_id;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20013, 'Пользователь с таким именем уже существует.');
    END IF;

    -- Проверка на уникальность нового email
    SELECT COUNT(*)
    INTO v_count
    FROM users
    WHERE LOWER(user_email) = LOWER(p_user_email)
      AND user_id != p_user_id;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20014, 'Пользователь с таким email уже существует.');
    END IF;

    -- Хешируем новый пароль
    v_hashed_password := hash_password(p_user_password);  -- Здесь вызываем вашу функцию хеширования

    -- Обновление данных пользователя
    UPDATE users
    SET user_name = p_user_name,
        user_email = p_user_email,
        user_password = v_hashed_password,
        user_role = p_role_id  -- Обновляем роль
    WHERE user_id = p_user_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Данные пользователя с ID ' || p_user_id || ' успешно обновлены.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка при обновлении данных пользователя: ' || SQLERRM);
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
        DBMS_OUTPUT.PUT_LINE('ID пользователя: ' || v_user_id || ', Имя: ' || v_user_name || 
                             ', Email: ' || v_user_email || ', Пароль (хеш): ' || v_user_password || 
                             ', Роль: ' || v_user_role);
    END LOOP;
    CLOSE user_cursor;
END get_all_users;
/
-- ===========================================
-- Пакет для управлением жанрами
-- ===========================================
CREATE OR REPLACE PROCEDURE add_genre(
    p_genre_name IN VARCHAR2
) AS
    v_count INTEGER;
BEGIN
    -- Проверка на пустое имя жанра
    IF p_genre_name IS NULL OR TRIM(p_genre_name) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Имя жанра не может быть пустым.');
    END IF;

    -- Проверка на уникальность жанра
    SELECT COUNT(*)
    INTO v_count
    FROM genres
    WHERE LOWER(genre_name) = LOWER(p_genre_name);

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Жанр с таким именем уже существует.');
    END IF;

    -- Вставка нового жанра
    INSERT INTO genres (genre_name)
    VALUES (p_genre_name);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Жанр "' || p_genre_name || '" успешно добавлен.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка при добавлении жанра: ' || SQLERRM);
END add_genre;
/

CREATE OR REPLACE PROCEDURE delete_genre(
    p_genre_id IN INTEGER
) AS
    v_count INTEGER;
BEGIN
    -- Проверка, существует ли жанр с таким ID
    SELECT COUNT(*)
    INTO v_count
    FROM genres
    WHERE genre_id = p_genre_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Жанр с таким ID не найден.');
    END IF;

    -- Удаление жанра
    DELETE FROM genres WHERE genre_id = p_genre_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Жанр с ID ' || p_genre_id || ' успешно удален.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка при удалении жанра: ' || SQLERRM);
END delete_genre;
/

CREATE OR REPLACE PROCEDURE update_genre(
    p_genre_id IN INTEGER,
    p_new_genre_name IN VARCHAR2
) AS
    v_count INTEGER;
BEGIN
    -- Проверка на пустое имя жанра
    IF p_new_genre_name IS NULL OR TRIM(p_new_genre_name) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20004, 'Имя жанра не может быть пустым.');
    END IF;

    -- Проверка на существование жанра с таким ID
    SELECT COUNT(*)
    INTO v_count
    FROM genres
    WHERE genre_id = p_genre_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Жанр с таким ID не найден.');
    END IF;

    -- Проверка на уникальность нового имени
    SELECT COUNT(*)
    INTO v_count
    FROM genres
    WHERE LOWER(genre_name) = LOWER(p_new_genre_name)
      AND genre_id != p_genre_id;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Жанр с таким именем уже существует.');
    END IF;

    -- Обновление имени жанра
    UPDATE genres
    SET genre_name = p_new_genre_name
    WHERE genre_id = p_genre_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Жанр с ID ' || p_genre_id || ' успешно обновлен.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка при обновлении жанра: ' || SQLERRM);
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
        DBMS_OUTPUT.PUT_LINE('ID жанра: ' || v_genre_id || ', Название: ' || v_genre_name);
    END LOOP;
    CLOSE genre_cursor;
END get_all_genres;
/

-------

CREATE OR REPLACE PROCEDURE add_song_to_playlist_user(
    p_playlist_id IN INTEGER,
    p_song_id IN INTEGER,
    p_user_id IN INTEGER  -- новый параметр для указания пользователя
) AS
    v_count INTEGER;
BEGIN
    -- Проверка на существование плейлиста с таким ID и принадлежность пользователю
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE playlist_id = p_playlist_id
    AND user_id = p_user_id;  -- добавлена проверка на принадлежность пользователю

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Плейлист с таким ID не найден или он не принадлежит указанному пользователю.');
    END IF;

    -- Проверка на существование песни с таким ID
    SELECT COUNT(*)
    INTO v_count
    FROM songs
    WHERE song_id = p_song_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Песня с таким ID не существует.');
    END IF;

    -- Добавление песни в плейлист
    INSERT INTO playlist_song (playlist_id, song_id)
    VALUES (p_playlist_id, p_song_id);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Песня с ID ' || p_song_id || ' успешно добавлена в плейлист с ID ' || p_playlist_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка при добавлении песни в плейлист: ' || SQLERRM);
END add_song_to_playlist_user;
/

CREATE OR REPLACE PROCEDURE remove_song_from_playlist_user(
    p_playlist_id IN INTEGER,
    p_song_id IN INTEGER,
    p_user_id IN INTEGER  -- новый параметр для указания пользователя
) AS
    v_count INTEGER;
BEGIN
    -- Проверка на существование плейлиста с таким ID и принадлежность пользователю
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE playlist_id = p_playlist_id
    AND user_id = p_user_id;  -- добавлена проверка на принадлежность пользователю

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Плейлист с таким ID не найден или он не принадлежит указанному пользователю.');
    END IF;

    -- Проверка на существование песни в указанном плейлисте
    SELECT COUNT(*)
    INTO v_count
    FROM playlist_song
    WHERE playlist_id = p_playlist_id
    AND song_id = p_song_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Песня с таким ID не найдена в плейлисте.');
    END IF;

    -- Удаление песни из плейлиста
    DELETE FROM playlist_song
    WHERE playlist_id = p_playlist_id
    AND song_id = p_song_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Песня с ID ' || p_song_id || ' успешно удалена из плейлиста с ID ' || p_playlist_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка при удалении песни из плейлиста: ' || SQLERRM);
END remove_song_from_playlist_user;
/

CREATE OR REPLACE PROCEDURE get_songs_from_playlist_user(
    p_playlist_id IN INTEGER,
    p_user_id IN INTEGER  -- новый параметр для указания пользователя
) AS
    CURSOR playlist_song_cursor IS
        SELECT ps.id, s.song_title, s.song_id
        FROM playlist_song ps
        JOIN songs s ON ps.song_id = s.song_id
        JOIN playlists p ON ps.playlist_id = p.playlist_id
        WHERE p.playlist_id = p_playlist_id
        AND p.user_id = p_user_id;  -- добавлена проверка на принадлежность пользователю
    
    v_id playlist_song.id%TYPE;
    v_song_title songs.song_title%TYPE;
    v_song_id songs.song_id%TYPE;
    v_count INTEGER;  -- добавлена переменная для подсчета количества плейлистов
BEGIN
    -- Проверка на существование плейлиста с таким ID и принадлежность пользователю
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE playlist_id = p_playlist_id
    AND user_id = p_user_id;  -- добавлена проверка на принадлежность пользователю

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Плейлист с таким ID не найден или он не принадлежит указанному пользователю.');
    END IF;

    OPEN playlist_song_cursor;
    LOOP
        FETCH playlist_song_cursor INTO v_id, v_song_title, v_song_id;
        EXIT WHEN playlist_song_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID песни: ' || v_song_id || ', Название: ' || v_song_title);
    END LOOP;
    CLOSE playlist_song_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка при просмотре песен в плейлисте: ' || SQLERRM);
END get_songs_from_playlist_user;
/

CREATE OR REPLACE PROCEDURE add_song_to_playlist(
    p_playlist_id IN INTEGER,
    p_song_id IN INTEGER
) AS
    v_count INTEGER;
BEGIN
    -- Проверка на существование плейлиста с таким ID
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE playlist_id = p_playlist_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Плейлист с таким ID не найден.');
    END IF;

    -- Проверка на существование песни с таким ID
    SELECT COUNT(*)
    INTO v_count
    FROM songs
    WHERE song_id = p_song_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Песня с таким ID не найдена.');
    END IF;

    -- Вставка песни в плейлист
    INSERT INTO playlist_song (playlist_id, song_id)
    VALUES (p_playlist_id, p_song_id);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Песня с ID ' || p_song_id || ' успешно добавлена в плейлист с ID ' || p_playlist_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка при добавлении песни в плейлист: ' || SQLERRM);
END add_song_to_playlist;
/

CREATE OR REPLACE PROCEDURE remove_song_from_playlist(
    p_playlist_id IN INTEGER,
    p_song_id IN INTEGER
) AS
    v_count INTEGER;
BEGIN
    -- Проверка на существование плейлиста с таким ID
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE playlist_id = p_playlist_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Плейлист с таким ID не найден.');
    END IF;

    -- Проверка на существование песни в плейлисте
    SELECT COUNT(*)
    INTO v_count
    FROM playlist_song
    WHERE playlist_id = p_playlist_id
    AND song_id = p_song_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Песня с таким ID не найдена в плейлисте.');
    END IF;

    -- Удаление песни из плейлиста
    DELETE FROM playlist_song
    WHERE playlist_id = p_playlist_id
    AND song_id = p_song_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Песня с ID ' || p_song_id || ' успешно удалена из плейлиста с ID ' || p_playlist_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка при удалении песни из плейлиста: ' || SQLERRM);
END remove_song_from_playlist;
/

CREATE OR REPLACE PROCEDURE get_songs_from_playlist(
    p_playlist_id IN INTEGER
) AS
    -- Объявление переменных
    v_count INTEGER;  -- добавляем переменную для проверки существования плейлиста
    CURSOR playlist_song_cursor IS
        SELECT ps.id, s.song_title, s.song_id
        FROM playlist_song ps
        JOIN songs s ON ps.song_id = s.song_id
        WHERE ps.playlist_id = p_playlist_id;
    
    v_id playlist_song.id%TYPE;
    v_song_title songs.song_title%TYPE;
    v_song_id songs.song_id%TYPE;
BEGIN
    -- Проверка на существование плейлиста с таким ID
    SELECT COUNT(*)
    INTO v_count
    FROM playlists
    WHERE playlist_id = p_playlist_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Плейлист с таким ID не найден.');
    END IF;

    OPEN playlist_song_cursor;
    LOOP
        FETCH playlist_song_cursor INTO v_id, v_song_title, v_song_id;
        EXIT WHEN playlist_song_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID песни: ' || v_song_id || ', Название: ' || v_song_title);
    END LOOP;
    CLOSE playlist_song_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка при просмотре песен в плейлисте: ' || SQLERRM);
END get_songs_from_playlist;
/