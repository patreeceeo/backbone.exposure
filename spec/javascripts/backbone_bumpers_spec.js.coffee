describe 'Backbone.Bumpers', ->

  it 'should be defined', ->
    expect(Backbone.Bumpers).toBeDefined()

  describe 'attribute name bumpers', ->
    ModelWithNameBumbers = null

    beforeEach ->
      class ModelWithNameBumbers extends Backbone.Model
        constructor: ->
          Backbone.Bumpers.add_attribute_name_bumpers.call(this)

      model1 = new ModelWithNameBumbers()

      model2 = new ModelWithNameBumbers
        color: 'yellow'
        name: 'gob'
        age: 35
      

  it 'should not allow us to create new attributes', ->
    expect(-> model1.set('hair', true)).toThrow()
    expect(-> model1.hair(true)).toThrow()
    expect(-> new Actor {occupation: true}).toThrow()
    expect(-> model2.set {poof: 'magazine', friends: []}).toThrow()
    
