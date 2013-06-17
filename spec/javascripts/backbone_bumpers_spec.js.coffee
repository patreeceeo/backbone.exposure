describe 'Backbone.Bumpers', ->

  it 'should be defined', ->
    expect(Backbone.Bumpers).toBeDefined()

  describe 'attribute name bumpers', ->
    model1 = null
    model2 = null

    beforeEach ->
      class Actor extends Backbone.Bumpers.Model
        defaults:
          color: 'blue'
          name: 'tobias'
          age: 34

      model1 = new Actor()

      model2 = new Actor
        color: 'yellow'
        name: 'gob'
        age: 35
        tricks: 'illusions'
      

    it 'should not allow us to create new attributes', ->
      expect(-> model1.set('hair', true)).toThrow()
      expect(-> new Actor {occupation: true}).toThrow()
      expect(-> model2.set {poof: 'magazine', friends: []}).toThrow()

    it 'should not allow us to `get` non-existent attributes', ->
      expect(-> model1.get('hair')).toThrow()
      expect(-> model2.get('teeth')).toThrow()

    it 'should allow us to get attributes that do exist', ->
      expect(-> model1.get('name')).not.toThrow()
      expect(-> model2.get('age')).not.toThrow()

    it 'should not allow us to change the type of attributes', ->
      expect(-> model1.set('name', 5)).toThrow()
      expect(-> model2.set('age', 'is just a number')).toThrow()


    
