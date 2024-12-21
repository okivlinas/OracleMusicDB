BEGIN
    FOR i IN 1..100000 LOOP
        INSERT INTO playlists (playlist_name) 
        VALUES ('Playlist_' || i);
    END LOOP;
    COMMIT;
END;

BEGIN
    FOR i IN 1..100000 LOOP
        INSERT INTO genres (genre_name) 
        VALUES ('Genre_' || i);
    END LOOP;
    COMMIT;
END;

SET TIMING ON;

SELECT *
FROM genres
WHERE genre_name LIKE 'Genre_1%'
ORDER BY genre_name;

SET TIMING OFF;

CREATE INDEX idx_genres_name ON genres(genre_name);
DROP INDEX idx_genre_name;

SELECT *
FROM genres
WHERE genre_name LIKE 'Genre_1%'
ORDER BY genre_name;