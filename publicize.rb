# Create an environment whereby a class method is made public for the
# purpose of testing it.
# When the environment closes, the method is made private.

class Class
  # Makes method public for the purpose of testing it
  def publicize(method)
    self.class_eval { public method }
    result = yield
    self.class_eval { private method }
    result
  end
end
