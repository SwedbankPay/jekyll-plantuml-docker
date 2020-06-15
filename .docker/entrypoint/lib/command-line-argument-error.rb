module Jekyll::PlantUml
  class CommandLineArgumentError < ArgumentError
    def initialize(message = "Invalid argument")
      super(message)
    end
  end
end
