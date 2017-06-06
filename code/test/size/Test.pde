class Test {

  int width;
  int height;

  Test() {
    println("uninitialized", width, height);
    width = 11;
    height = 11;
    println("this", this.width, this.height);

    ////java.lang.Object = super;
    ////println("super", super.width, super.height);
    //// Java.lang.Object
    //// Java.lang.Class
    //println("Java...");
    //Class c = this.getClass();
    //println(c);
    //println("getName", c.getName());
    //println("getSimpleName", c.getSimpleName());
    //println("getCanonicalName", c.getCanonicalName());
    ////println(c.getFields());
    //println(c.getDeclaredFields());
    ////println(c.getMethods());
    //println(c.getDeclaredMethods());
    //println("getEnclosingClass", c.getEnclosingClass());
    //println(c.getDeclaringClass());
    ////and more!
    //// instanceof comparison operator
    
    println(super.getClass().getName());
  }
}