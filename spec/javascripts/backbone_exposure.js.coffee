describe 'Exposure', ->

  it 'should be defined', ->
    expect(Exposure).toBeDefined()

  describe 'the methods created for attributes', ->
    model1 = null
    model2 = null

    beforeEach ->
      class Actor extends Exposure.Model
        defaults:
          color: 'blue'
          name: 'tobias'
          age: 34
        jump: -> console.log 'whooo!'

      model1 = new Actor()

      model2 = new Actor
        color: 'yellow'
        name: 'gob'
        age: 35
        tricks: 'illusions'
      
    it 'should define methods for each initial attribute', ->
      expect(model1.color).toBeDefined()
      expect(model1.name).toBeDefined()
      expect(model1.age).toBeDefined()
      expect(model2.color).toBeDefined()
      expect(model2.name).toBeDefined()
      expect(model2.age).toBeDefined()
      expect(model2.tricks).toBeDefined()

    it 'should make each method act as a getter', ->
      expect(model1.color()).toBe 'blue'
      expect(model1.name()).toBe 'tobias'
      expect(model1.age()).toBe 34
      expect(model2.color()).toBe 'yellow'
      expect(model2.name()).toBe 'gob'
      expect(model2.age()).toBe 35
      expect(model2.tricks()).toBe 'illusions'

    it 'should make each method act as a setter', ->
      model1.color 'white'
      model1.name 'Mrs. Featherbottom'
      model1.age 35
      model2.color 'brown'
      model2.name 'el pollo'
      model2.age [1,2,3]
      model2.tricks false
      expect(model1.color()).toBe 'white'
      expect(model1.name()).toBe 'Mrs. Featherbottom'
      expect(model1.age()).toBe 35
      expect(model2.color()).toBe 'brown'
      expect(model2.name()).toBe 'el pollo'
      expect(model2.age()).toEqual [1,2,3]
      expect(model2.tricks()).toBe false

    it 'should not clobber statically-defined methods', ->
      expect(-> new Actor {set: 'The Queen Mary'}).toThrow()
      expect(-> new Actor {constructor: 'The Queen Mary'}).toThrow()
      expect(-> new Actor {get: 'The Queen Mary'}).toThrow()
      expect(-> new Actor {jump: 'The Queen Mary'}).toThrow()

  describe 'the attributes created for methods', ->
    model1 = null
    model2 = null
    Actor = null

    beforeEach ->
      class Actor extends Exposure.Model
        color: -> 'blue'
        name: -> 'tobias'
        age: -> 34

      model1 = new Actor()


    it 'should call each method and include the results in the JSON form.', ->
      json1 = model1.toJSON()
      expect(json1.color).toBe 'blue'
      expect(json1.name).toBe 'tobias'
      expect(json1.age).toBe 34
        
    it "should try to invoke a synonymous method for each key in the
initial attributes, arguing the associated value", ->
      method = sinon.spy()

      class DenzelWashington extends Actor
        doIt: method

      dnzl = new DenzelWashington
        doIt: ['right', 'now']
      
      expect(method).toHaveBeenCalledWith('right', 'now')

    
