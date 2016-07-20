public class AppConfig {

    private static ApplicationContext context;

    public static void main(String[] args) {
	ApplicationContext appContext = SpringApplication.run(AppConfig.class);
        context = appContext;
        LOG.info("Service started successfully.");
    }
}
