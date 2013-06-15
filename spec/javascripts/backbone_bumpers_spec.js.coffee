describe 'Backbone.Bumpers', ->

  it 'should be defined', ->
    expect(Backbone.Bumpers).toBeDefined()

  describe 'attribute name bumpers', ->
    ModelWithNameBumbers = null
    model1 = null
    model2 = null

    beforeEach ->
      class ModelWithNameBumbers extends Backbone.Bumpers(Backbone.Model,
        name_bumpers: -> @defaults
      )
        defaults: 
          color: 'blue'
          name: 'tobias'
          age: 34
        constructor: ->
          super
          Backbone.Bumpers.for_attribute_names.call(this, @defaults)

      model1 = new ModelWithNameBumbers()

      model2 = new ModelWithNameBumbers
        color: 'yellow'
        name: 'gob'
        age: 35
      

    it 'should not allow us to create new attributes', ->
      expect(-> model1.set('hair', true)).toThrow()
      expect(-> new Actor {occupation: true}).toThrow()
      expect(-> model2.set {poof: 'magazine', friends: []}).toThrow()

    it 'should not allow us to `get` non-existent attributes', ->
      expect(-> model1.get('hair')).toThrow()

    it 'should allow us to get attributes that do exist', ->
      expect(-> model1.get('name')).not.toThrow()
      model1.get('name')
    
