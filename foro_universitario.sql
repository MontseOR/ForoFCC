-- ============================================================
--  Foro Universitario · Script de Creación de Tablas
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ------------------------------------------------------------
-- 1. AUTENTICACIÓN Y USUARIOS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS Roles (
    ID_rol      INT          NOT NULL AUTO_INCREMENT,
    descripcion VARCHAR(100) NOT NULL,
    moderar     BOOLEAN      NOT NULL DEFAULT FALSE,
    publicar    BOOLEAN      NOT NULL DEFAULT TRUE,
    PRIMARY KEY (ID_rol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS Usuarios (
    ID_usuario  INT          NOT NULL AUTO_INCREMENT,
    username    VARCHAR(50)  NOT NULL,
    email       VARCHAR(100) NOT NULL,
    contrasena  VARCHAR(255) NOT NULL,
    avatar      VARCHAR(255),
    ID_rol      INT          NOT NULL,
    actividad   BOOLEAN      NOT NULL DEFAULT TRUE,
    PRIMARY KEY (ID_usuario),
    UNIQUE KEY UK_email (email),
    CONSTRAINT FK_usuarios_rol
        FOREIGN KEY (ID_rol) REFERENCES Roles (ID_rol)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS Autenticacion (
    ID_auth     INT          NOT NULL AUTO_INCREMENT,
    ID_usuario  INT          NOT NULL,
    tipo        ENUM('login','registro','reset') NOT NULL,
    fecha       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    token       VARCHAR(255),
    PRIMARY KEY (ID_auth),
    CONSTRAINT FK_auth_usuario
        FOREIGN KEY (ID_usuario) REFERENCES Usuarios (ID_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ------------------------------------------------------------
-- 2. CONTENIDO DEL FORO
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS Categorias (
    ID_categoria    INT          NOT NULL AUTO_INCREMENT,
    tipo_categoria  VARCHAR(100) NOT NULL,
    nombre_categoria VARCHAR(150) NOT NULL,
    icono           VARCHAR(50),
    color           VARCHAR(7),          -- Formato HEX: #RRGGBB
    orden           INT          NOT NULL DEFAULT 0,
    PRIMARY KEY (ID_categoria),
    UNIQUE KEY UK_tipo_categoria (tipo_categoria)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS Post (
    ID_post      INT          NOT NULL AUTO_INCREMENT,
    ID_autor     INT          NOT NULL,
    ID_categoria INT          NOT NULL,
    titulo       VARCHAR(300) NOT NULL,
    contenido    TEXT         NOT NULL,
    creacion     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    estado       ENUM('activo','eliminado') NOT NULL DEFAULT 'activo',
    PRIMARY KEY (ID_post),
    CONSTRAINT FK_post_autor
        FOREIGN KEY (ID_autor) REFERENCES Usuarios (ID_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT FK_post_categoria
        FOREIGN KEY (ID_categoria) REFERENCES Categorias (ID_categoria)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS Comentarios (
    ID_comentario INT     NOT NULL AUTO_INCREMENT,
    ID_post       INT     NOT NULL,
    ID_autor      INT     NOT NULL,
    contenido     TEXT    NOT NULL,
    creacion      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    eliminado     BOOLEAN NOT NULL DEFAULT FALSE,
    ID_respuesta  INT     DEFAULT NULL,   -- NULL = comentario raíz
    PRIMARY KEY (ID_comentario),
    CONSTRAINT FK_comentario_post
        FOREIGN KEY (ID_post) REFERENCES Post (ID_post)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_comentario_autor
        FOREIGN KEY (ID_autor) REFERENCES Usuarios (ID_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT FK_comentario_padre
        FOREIGN KEY (ID_respuesta) REFERENCES Comentarios (ID_comentario)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ------------------------------------------------------------
-- 3. INTERACCIÓN
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS Votos_post (
    ID_votos   INT      NOT NULL AUTO_INCREMENT,
    ID_usuario INT      NOT NULL,
    ID_post    INT      NOT NULL,
    valor      ENUM('upvote','downvote') NOT NULL,
    creacion   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ID_votos),
    UNIQUE KEY UK_voto_unico (ID_usuario, ID_post),
    CONSTRAINT FK_voto_usuario
        FOREIGN KEY (ID_usuario) REFERENCES Usuarios (ID_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_voto_post
        FOREIGN KEY (ID_post) REFERENCES Post (ID_post)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS Likes_comentarios (
    ID_like       INT      NOT NULL AUTO_INCREMENT,
    ID_usuario    INT      NOT NULL,
    ID_comentario INT      NOT NULL,
    creacion      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ID_like),
    UNIQUE KEY UK_like_unico (ID_usuario, ID_comentario),
    CONSTRAINT FK_like_usuario
        FOREIGN KEY (ID_usuario) REFERENCES Usuarios (ID_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_like_comentario
        FOREIGN KEY (ID_comentario) REFERENCES Comentarios (ID_comentario)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS Notificaciones (
    ID_noti       INT      NOT NULL AUTO_INCREMENT,
    ID_usuario    INT      NOT NULL,
    tipo_noti     ENUM('comentario','voto','like','mencion') NOT NULL,
    ID_post       INT      DEFAULT NULL,
    ID_comentario INT      DEFAULT NULL,
    leida         BOOLEAN  NOT NULL DEFAULT FALSE,
    creacion      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ID_noti),
    CONSTRAINT FK_noti_usuario
        FOREIGN KEY (ID_usuario) REFERENCES Usuarios (ID_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_noti_post
        FOREIGN KEY (ID_post) REFERENCES Post (ID_post)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_noti_comentario
        FOREIGN KEY (ID_comentario) REFERENCES Comentarios (ID_comentario)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
--  Fin del script · Foro Universitario
-- ============================================================
