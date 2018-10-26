/**
 * @author Maxim Sorokin [m.s.v.00a@gmail.com]
 */
public class ApplicationContext implements Component {

    private Map<Type, Object> foundComponentsInstances;
    private static ApplicationContext instance;

    public static ApplicationContext start() {
        if (instance == null) {
            instance = new ApplicationContext();
        }

        return instance;
    }

    private ApplicationContext() {
        this.foundComponentsInstances = new Map<Type, Object>();
        this.foundComponentsInstances.put(this.registerAs(), this);
        this.scan();
    }

    private void scan() {
        Set<Type> componentsClasses =
            Reflection.getTypesThatImplements(
                new Set<Type> { Component.class });
        Set<Type> componentsAutowiredClasses =
            Reflection.getTypesThatImplements(
                new Set<Type> { Component.class, Autowired.class });
        Set<Type> componentsClassesWithoutAutowired =
            ApplicationContext.excludeClassesWithAutowired(
                componentsClasses, componentsAutowiredClasses);


        componentsClasses.remove(ApplicationContext.class);
        componentsAutowiredClasses.remove(ApplicationContext.class);
        componentsClassesWithoutAutowired.remove(ApplicationContext.class);


        for (Type type_i : componentsClassesWithoutAutowired) {
            Component typeInstance = (Component) type_i.newInstance();

            this.foundComponentsInstances.put(
                typeInstance.registerAs(), typeInstance);
        }

        Set<Type> notYetInstancietedTypes =
            new Set<Type>(componentsAutowiredClasses);

        while (notYetInstancietedTypes.size() > 0) {
            Integer notYetInstancietedTypesInitialSize =
                notYetInstancietedTypes.size();

            Object typeInstance;

            for (Type type_i : notYetInstancietedTypes) {
                Constructor constructorThatHasAllParamsAlreadyInstancieted;

                Set<Constructor> typeConstructors =
                    Reflection.getConstructors(type_i);

                for (Constructor constructor_i : typeConstructors) {
                    Boolean constructorHasAllParametersInstancieted = true;

                    for (Parameter parameter_i :
                                constructor_i.getParams())
                    {
                        if (!this.foundComponentsInstances.keySet().contains(
                                parameter_i.getType()))
                        {
                            constructorHasAllParametersInstancieted = false;
                        }
                    }

                    if (constructorHasAllParametersInstancieted) {
                        constructorThatHasAllParamsAlreadyInstancieted =
                            constructor_i;
                    }
                }

                if (constructorThatHasAllParamsAlreadyInstancieted != null) {
                    List<Object> params = new List<Object>();

                    for (Parameter param_i :
                            constructorThatHasAllParamsAlreadyInstancieted.getParams())
                    {
                        params.add(
                            this.foundComponentsInstances.get(param_i.getType()));
                    }

                    typeInstance =
                        JSON.deserialize('{}', type_i);

                    ((Autowired) typeInstance).init(params);

                    break;
                }
            }

            if (typeInstance != null) {
                this.foundComponentsInstances.put(
                    ((Component) typeInstance).registerAs(), typeInstance);

                notYetInstancietedTypes.remove(
                    Reflection.getObjectType(typeInstance));
            }

            if (notYetInstancietedTypes.size() ==
                    notYetInstancietedTypesInitialSize)
            {
                break;
            }
        }
    }

    private static Set<Type> excludeClassesWithAutowired(
        Set<Type> componentsClasses,
        Set<Type> componentsAutowiredClasses)
    {
        Set<Type> componentsClassesWithoutAutowired = new Set<Type>();

        for (Type type_i : componentsClasses) {
            if (!componentsAutowiredClasses.contains(type_i)) {
                componentsClassesWithoutAutowired.add(type_i);
            }
        }

        return componentsClassesWithoutAutowired;
    }

    public Object getInstance(Type type) {
        return this.foundComponentsInstances.get(type);
    }

    public Type registerAs() {
        return ApplicationContext.class;
    }
}