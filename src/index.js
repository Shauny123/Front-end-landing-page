export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    url.hostname = 'bywordofmouthlegal.com';
    return Response.redirect(url.toString(), 301);
  },
};
