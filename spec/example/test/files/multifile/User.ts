// START AUTOGEN

import type { UserRole } from "./shared";
import type { Comment } from "./Comment";
import type { Post } from "./Post";

type Model = {
  id: number;
  type: "users";
  name: string;
  role: UserRole;
  relationships: {
    comments: Array<Comment>;
    posts: Array<Post>;
  };
};

// END AUTOGEN

type User = Model;

export { type User };
