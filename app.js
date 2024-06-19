const dir_nms = 'C:\\Users\\khudo\\node_modules\\sync-mysql';
const Mysql = require(dir_nms);
const http = require('http');
const fs = require('fs');
const qs = require('querystring');

const connection = new Mysql({
    host: 'localhost',
    user: 'root',
    password: '1111',
    database: 'lab2',
    charset: 'utf8mb4'
});

function reqPost(request, response) {
    if (request.method == 'POST') {
        let body = '';
        request.on('data', function (data) {
            body += data;
        });
        request.on('end', function () {
            const post = qs.parse(body);
            console.log('Получены POST данные: ', post);

            if (post['action'] === 'delete') {
                // Логика удаления записи
                // ...
            } else if (post['action'] === 'insert') {
                if (post['galactic_id'] && post['coordinates'] && post['light_intensity'] && post['foreign_objects'] && post['number_of_starry_sky_objects'] && post['number_undefined_objects'] && post['number_of_specified_objects'] && post['notes']) {
                    const sInsert = `INSERT INTO sector (galactic_id, coordinates, light_intensity, foreign_objects, number_of_starry_sky_objects, number_undefined_objects, number_of_specified_objects, notes) VALUES ("${post['galactic_id']}", "${post['coordinates']}", "${post['light_intensity']}", "${post['foreign_objects']}", "${post['number_of_starry_sky_objects']}", "${post['number_undefined_objects']}", "${post['number_of_specified_objects']}", "${post['notes']}")`;
                    connection.query(sInsert, (error, results, fields) => {
                        if (error) {
                            console.log('Ошибка при добавлении данных в базу данных:', error);
                        } else {
                            console.log('Добавлено. Подсказка: ' + sInsert);
                            // После успешной вставки данных обновляем содержимое страницы
                            response.writeHead(302, {
                                'Location': '/'
                            });
                            response.end();
                        }
                    });
                } else {
                    console.log('Ошибка: Все поля формы должны быть заполнены!');
                }
            } else if (post['action'] === 'edit') {
                // Логика редактирования записи
                // ...
            }
        });
    }
}

function viewSelect(res) {
    let results = connection.query('SHOW COLUMNS FROM sector');
    res.write('<tr>');
    for (let i = 0; i < results.length; i++)
        res.write('<td>' + results[i].Field + '</td>');
    res.write('<td>Действия</td>');
    res.write('</tr>');

    results = connection.query('SELECT * FROM sector');
    for (let i = 0; i < results.length; i++) {
        res.write('<tr>');
        res.write('<td>' + results[i].id + '</td>');
        res.write('<td>' + results[i].coordinates + '</td>');
        res.write('<td>' + results[i].light_intensity + '</td>');
        res.write('<td>' + results[i].foreign_objects + '</td>');
        res.write('<td>' + results[i].number_of_starry_sky_objects + '</td>');
        res.write('<td>' + results[i].number_undefined_objects + '</td>');
        res.write('<td>' + results[i].number_of_specified_objects + '</td>');
        res.write('<td><form method="post"><input type="hidden" name="id" value="' + results[i].id + '"/><input type="hidden" name="action" value="delete"/><input type="submit" value="Удалить"/></form></td>');
        res.write('<td><form method="post"><input type="hidden" name="id" value="' + results[i].id + '"/><input type="hidden" name="action" value="edit"/><input type="submit" value="Редактировать"/></form></td>');
        res.write('</tr>');
    }
}

function viewVer(res) {
    const results = connection.query('SELECT VERSION() AS ver');
    res.write(results[0].ver);
}

const server = http.createServer((req, res) => {
    reqPost(req, res);
    console.log('Загрузка...');

    res.statusCode = 200;

    const array = fs.readFileSync(__dirname + '\\select.html').toString().split("\n");
    console.log(__dirname + '\\select.html');
    for (let i in array) {
        if ((array[i].trim() != '@tr') && (array[i].trim() != '@ver')) res.write(array[i]);
        if (array[i].trim() == '@tr') viewSelect(res);
        if (array[i].trim() == '@ver') viewVer(res);
    }
    res.end();
    console.log('Пользователь завершил работу.');
});

const hostname = '127.0.0.1';
const port = 3000;
server.listen(port, hostname, () => {
    console.log(`Сервер запущен по адресу http://${hostname}:${port}/`);
});
