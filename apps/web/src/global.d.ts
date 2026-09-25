import type messages from '../messages/es.json';

// Makes translation keys type-checked: a missing key fails the build.
declare module 'next-intl' {
  interface AppConfig {
    Messages: typeof messages;
  }
}
