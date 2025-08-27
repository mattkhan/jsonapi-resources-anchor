// START AUTOGEN

import type { Maybe } from "./shared";

type Model = {
  id: number;
  type: "exhaustives";
  /** My asserted string. */
  assertedString: string;
  assertedNumber: number;
  assertedBoolean: boolean;
  assertedNull: null;
  assertedUnknown: unknown;
  assertedObject: {
    a: "a";
    "b-dash": 1;
    c: Maybe<string>;
    d_optional?: Maybe<string>;
  };
  assertedMaybeObject: Maybe<{
    a: "a";
    "b-dash": 1;
    c: Maybe<string>;
    d_optional?: Maybe<string>;
  }>;
  assertedArrayRecord: Array<Record<string, number>>;
  assertedUnion: string | number;
  assertedUnionArray: Array<string | number>;
  /** This is a provided description. */
  withDescription: string;
  inferredUnknown: unknown;
  uuid: string;
  string: string;
  maybeString: string;
  text: string;
  integer: number;
  float: number;
  decimal: string;
  datetime: string;
  timestamp: string;
  time: string;
  date: string;
  boolean: boolean;
  arrayString: Array<string>;
  maybeArrayString: Maybe<Array<string>>;
  json: Record<string, unknown>;
  jsonb: Record<string, unknown>;
  daterange: unknown;
  enum: unknown;
  virtualUpcasedString: Maybe<string>;
  loljk: "never";
  delegatedMaybeString: string;
  modelOverridden: unknown;
  resourceOverridden: unknown;
  /** This is a comment. */
  withComment: Maybe<string>;
  defaultedBoolean: boolean;
  defaultedAt: string;
  relationships: {};
  meta: {
    some_count: number;
    extra_stuff: string;
  };
  links: {
    self: string;
    some_url: string;
  };
};

// END AUTOGEN

type Exhaustive = Model;

export { type Exhaustive };
