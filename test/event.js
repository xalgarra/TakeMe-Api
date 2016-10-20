"use strict"
let request = require('supertest-as-promised');
const api = require('../app');
const host = api;
const mysql = require('promise-mysql');

request = request(host);

var pool  = mysql.createPool({ // No vull repetir codi però quan estigui més complet ja faré un refactor.
  host     : 'localhost',
  user     : 'root',
  password : '12345678',
  database : 'takemelegends'
});

var event = {
  'name': 'name proves 01',
  'description': 'description testing 01',
  'startTime' : "2017-01-12T15:30:00Z",
  'endTime' : "2017-02-12T09:00:00Z",
  'category_id' : '1',
  'capacity' : '15000',
  'price' : 257.13,
  'address' : 'carrer fals, Barcelona',
  'coords' : {
    'latitude' : 41.38879,
    'longitude' : 2.15899
  }
}
var aux_id;

describe('route of events', function() {

  this.timeout(6000); // Per fer proves

  // QUEDA PENDENT EL CATEGORY!!
  // Queda pendent fer el DELETE al final del que he creat aquí
  // Em sembla que la API d'Eventbrite suma 1h al temps que li envio LOL

  describe('POST /events', function() {
    it('should create an event', function(done) {
      pool.getConnection().then(function(mysqlConnection) {
        request
          .post('/events')
          .set('Accept', 'application/json')
          .send(event)
          .expect(201)
          .expect('Content-Type', /application\/json/)
        .end((err, res) => {
          expect(res.body).to.have.property('event')
          const eventResponse = res.body.event

          expect(eventResponse).to.have.property('id').and.to.be.a('number')
          expect(eventResponse).to.have.property('name', event.name)
          expect(eventResponse).to.have.property('description', event.description)
          expect(eventResponse).to.have.property('url')
          expect(eventResponse).to.have.property('resource_uri')
          expect(eventResponse).to.have.property('start')
          expect(eventResponse).to.have.property('end')
          expect(eventResponse).to.have.property('capacity')
          expect(eventResponse).to.have.property('category_id')
          expect(eventResponse).to.have.property('logo')
          expect(eventResponse).to.have.property('price', event.price)
          expect(eventResponse).to.have.property('address', event.address)
          expect(eventResponse).to.have.property('latitude', event.coords.latitude)
          expect(eventResponse).to.have.property('longitude', event.coords.longitude)

          done(err)
        })
      });
    })
  })

/*
  describe('GET /events', function() {
    // TO DO
  });
*/

  describe('GET /events/:id', function() {
    it('should obtain an event with all its info when that event was created from our app', function(done) {
      let event_aux = event;
      event_aux.name = "Títol 01";
      event_aux.description = "Descripció random 01";
      request
        .post('/events')
        .set('Accept', 'application/json')
        .send(event_aux)
        .expect(201)
        .expect('Content-Type', /application\/json/)
      .then((res) => {
        aux_id = res.body.event.id;
      })
      .catch((err) => {
        console.log("Error: " + JSON.stringify(err));
      })
      .finally(() => {
        request
          .get('/events/' + aux_id)
          .set('Accept', 'application/json')
          .expect(200)
          .expect('Content-Type', /application\/json/)
        .then((res) => {
          expect(JSON.parse(res.text)).to.have.property('event')
          const eventResponse = JSON.parse(res.text).event;

          expect(eventResponse).to.have.property('id', parseInt(aux_id))
          expect(eventResponse).to.have.property('name', event_aux.name)
          expect(eventResponse).to.have.property('description', event_aux.description)
          expect(eventResponse).to.have.property('url')
          expect(eventResponse).to.have.property('resource_uri')
          expect(eventResponse).to.have.property('start')
          expect(eventResponse).to.have.property('end')
          expect(eventResponse).to.have.property('capacity')
          expect(eventResponse).to.have.property('category_id')
          expect(eventResponse).to.have.property('logo')
          expect(eventResponse).to.have.property('price', event.price)
          expect(eventResponse).to.have.property('address', event.address)
          expect(eventResponse).to.have.property('latitude', event.coords.latitude)
          expect(eventResponse).to.have.property('longitude', event.coords.longitude)

          done();
        }, done)
      });
    });
    it('should obtain an event with all its info when that event was not created from our app', function(done) {
      aux_id = 27817268198;  // 27817268198 27880689894
      request
        .get('/events/' + aux_id)
        .set('Accept', 'application/json')
        .expect(200)
        .expect('Content-Type', /application\/json/)
      .then((res) => {
        expect(JSON.parse(res.text)).to.have.property('event')
        const eventResponse = JSON.parse(res.text).event;

        expect(eventResponse).to.have.property('id', parseInt(aux_id))
        expect(eventResponse).to.have.property('name')
        expect(eventResponse).to.have.property('description')
        expect(eventResponse).to.have.property('url')
        expect(eventResponse).to.have.property('resource_uri')
        expect(eventResponse).to.have.property('start')
        expect(eventResponse).to.have.property('end')
        expect(eventResponse).to.have.property('capacity')
        expect(eventResponse).to.have.property('category_id')
        expect(eventResponse).to.have.property('logo')
        expect(eventResponse).to.have.property('price')
        expect(eventResponse).to.have.property('address')
        expect(eventResponse).to.have.property('latitude')
        expect(eventResponse).to.have.property('longitude')

        done();
      }, done)
    });
  });


  describe('PUT: /events/:id', function() {
    it('should update an event when that event was created from our app', function(done) {
      let event_aux = event;
      event_aux.name = "Esdeveniment per ser modificaaaaat!";
      event_aux.description = "Descripció de l'esdeveniment que serà actualitzat";
      event_aux.coords = {
        'latitude' : 40.7829,
        'longitude' : -73.9654
      };
      event_aux.price = 0;
      request
        .post('/events')
        .set('Accept', 'application/json')
        .send(event_aux)
        .expect(201)
        .expect('Content-Type', /application\/json/)
      .then((res) => {
        aux_id = res.body.event.id;
      })
      .catch((err) => {
        console.log("Error: " + JSON.stringify(err));
      })
      .finally(() => {
        event.name = 'Nou Títol de lesdeveniment editat';
        event.description = 'Nova descripció de lesdeveniment editat';
        request
          .put('/events/' + aux_id)
          .set('Accept', 'application/json')
          .send(event)
          .expect(200)
          .expect('Content-Type', /application\/json/)
        .then((res) => {
          let body = res.body

          expect(body).to.have.property('event')
          let event_res = body.event;

          expect(event_res).to.have.property('id', parseInt(aux_id))
          expect(event_res).to.have.property('name', event_aux.name)
          expect(event_res).to.have.property('description', event_aux.description)
          expect(event_res).to.have.property('url')
          expect(event_res).to.have.property('resource_uri')
          expect(event_res).to.have.property('start')
          expect(event_res).to.have.property('end')
          expect(event_res).to.have.property('capacity')
          //expect(event_res).to.have.property('category_id')
          expect(event_res).to.have.property('logo')
          expect(event_res).to.have.property('price', event_aux.price)
          expect(event_res).to.have.property('address', event.address)
          expect(event_res).to.have.property('latitude', event_aux.coords.latitude)
          expect(event_res).to.have.property('longitude', event_aux.coords.longitude)

          done();
        }, done)
      });
    });
    it('should not update an event when that event was not created from our app', function(done) {
      aux_id = 27817268198;  // 27817268198 27880689894
      request
        .put('/events/' + aux_id)
        .set('Accept', 'application/json')
        .send(event)
        .expect(403)
        .expect('Content-Type', /application\/json/)
      .then((res) => {
        done();
      }, done)
    })
  })


  describe('DELETE:  /events/:id', function() {
    it('should delete an event when that event was created from our app', function(done) {
        let event_aux = event;
        event_aux.name = "Esdeveniment per ser esborrat - més proves";
        event_aux.description = "Descripció de l'esdeveniment que serà esborrat";
        request
          .post('/events')
          .set('Accept', 'application/json')
          .send(event_aux)
          .expect(201)
          .expect('Content-Type', /application\/json/)
        .then((res) => {
          aux_id = res.body.event.id;
        })
        .catch((err) => {
          console.log("Error: " + JSON.stringify(err));
        })
        .finally(() => {
          request
            .delete('/events/' + aux_id)
            .set('Accept', 'application/json')
            .expect(200)
            .expect('Content-Type', /application\/json/)
          .then((res) => {
            expect(res.body).to.be.empty
            done();
          }, done)
        });
    });
    it('should not delete an event when that event was not created from our app', function(done) {
      aux_id = 27817268198;  // 27817268198 27880689894
      request
        .put('/events/' + aux_id)
        .set('Accept', 'application/json')
        .send(event)
        .expect(403)
        .expect('Content-Type', /application\/json/)
      .then((res) => {
        done();
      }, done)
    })
  })


});
