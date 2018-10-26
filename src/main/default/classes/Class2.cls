public class Class2
    implements
        Component, Autowired
{
    public Interface1 testInstance;

    public Class2(Interface1 testInstance) {
        this.init(new List<Object> {
            testInstance
        });
    }

    public Class2(Class2 copy) {
    }

    public void init(List<Object> params) {
        this.testInstance =
            (Interface1) params.get(0);
    }

    public Type registerAs() {
        return Class2.class;
    }
}
